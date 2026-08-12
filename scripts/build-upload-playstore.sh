#!/usr/bin/env bash
set -euo pipefail

# Build signed AAB, then upload it to Google Play via Android Publisher API.
# No Ruby/Fastlane.
# Usage:
#   ./build-upload-playstore.sh [scripts/build-play-console.sh args...]
#   ./build-upload-playstore.sh --skip-build  # upload LATEST_AAB only
#   ./build-upload-playstore.sh --prebuilt-aab path/to/app.aab \
#     --expected-version 1.2.3 --expected-build-number 123
# Env:
#   PLAY_TRACK=internal|alpha|beta|production   default: internal
#   PLAY_RELEASE_STATUS=completed|draft        default: draft
#   PLAY_SERVICE_ACCOUNT_JSON=path             default: play-console-upload/play-service-account.json
#   PLAY_LISTING_LOCALE=locale                  default: en-US
#   PLAY_LISTING_ICON=path                      optional exact approved 512px icon
#   PLAY_LISTING_ICON_SHA256=hex                required with PLAY_LISTING_ICON
#   PLAY_RECEIPT_PATH=path                      durable redacted receipt output

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

PACKAGE_NAME="${PLAY_PACKAGE_NAME:-com.trebuchetdynamics.fractal.forge}"
TRACK="${PLAY_TRACK:-internal}"
RELEASE_STATUS="${PLAY_RELEASE_STATUS:-draft}"
KEY_JSON="${PLAY_SERVICE_ACCOUNT_JSON:-play-console-upload/play-service-account.json}"
TMP_FILES=()
SKIP_BUILD=0
PREBUILT_AAB=""
EXPECTED_VERSION=""
EXPECTED_BUILD_NUMBER=""
LISTING_LOCALE="${PLAY_LISTING_LOCALE:-en-US}"
LISTING_ICON="${PLAY_LISTING_ICON:-}"
LISTING_ICON_SHA256="${PLAY_LISTING_ICON_SHA256:-}"
RECEIPT_PATH="${PLAY_RECEIPT_PATH:-play-console-upload/play-publication-receipt.json}"

log() { echo "[build-upload-playstore] $*"; }
die() { echo "[build-upload-playstore] ERROR: $*" >&2; exit 1; }
usage() {
  sed -n '3,12p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'
  echo
  scripts/build-play-console.sh --help
}
cleanup() { rm -f "${TMP_FILES[@]:-}"; }
trap cleanup EXIT

BUILD_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --skip-build)
      SKIP_BUILD=1
      shift
      ;;
    --prebuilt-aab)
      [[ $# -ge 2 ]] || die "--prebuilt-aab requires a path"
      PREBUILT_AAB="$2"
      SKIP_BUILD=1
      shift 2
      ;;
    --prebuilt-aab=*)
      PREBUILT_AAB="${1#*=}"
      SKIP_BUILD=1
      shift
      ;;
    --expected-version)
      [[ $# -ge 2 ]] || die "--expected-version requires a value"
      EXPECTED_VERSION="$2"
      shift 2
      ;;
    --expected-version=*)
      EXPECTED_VERSION="${1#*=}"
      shift
      ;;
    --expected-build-number)
      [[ $# -ge 2 ]] || die "--expected-build-number requires a value"
      EXPECTED_BUILD_NUMBER="$2"
      shift 2
      ;;
    --expected-build-number=*)
      EXPECTED_BUILD_NUMBER="${1#*=}"
      shift
      ;;
    *)
      BUILD_ARGS+=("$1")
      shift
      ;;
  esac
done

need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found"; }
ensure_bundletool() {
  local version=1.18.3
  local expected_sha256=a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29
  local jar="${BUNDLETOOL_JAR:-$HOME/.cache/fractal-forge/bundletool-all-${version}.jar}"
  local download="${jar}.download"
  if [[ ! -f "$jar" || "$(sha256sum "$jar" | awk '{ print $1 }')" != "$expected_sha256" ]]; then
    mkdir -p "$(dirname "$jar")"
    rm -f "$download"
    curl -fL "https://github.com/google/bundletool/releases/download/${version}/bundletool-all-${version}.jar" \
      -o "$download"
    [[ "$(sha256sum "$download" | awk '{ print $1 }')" == "$expected_sha256" ]] || {
      rm -f "$download"
      die "bundletool checksum verification failed"
    }
    mv "$download" "$jar"
  fi
  printf '%s\n' "$jar"
}
json_field() { python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1"; }
b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }
request() {
  local body status
  body="$(mktemp)"; TMP_FILES+=("$body")
  status="$(curl -sS -w '%{http_code}' -o "$body" "$@")" || { cat "$body" >&2; die "curl failed"; }
  if [[ ! "$status" =~ ^2 ]]; then
    cat "$body" >&2
    die "HTTP $status"
  fi
  cat "$body"
}

[[ -f "$KEY_JSON" ]] || die "Missing service account JSON: $KEY_JSON"
need curl
need java
need openssl
need python3
need sha256sum

if [[ "$SKIP_BUILD" -eq 0 ]]; then
  scripts/build-play-console.sh "${BUILD_ARGS[@]}"
fi

if [[ -n "$PREBUILT_AAB" ]]; then
  AAB="$PREBUILT_AAB"
else
  AAB="$(tr -d '\r\n' < play-console-upload/LATEST_AAB.txt)"
fi
[[ -f "$AAB" ]] || die "Built AAB not found: $AAB"

INFO="play-console-upload/LATEST_BUILD_INFO.txt"
VERSION_NAME="$(awk -F= '$1=="versionName" {print $2}' "$INFO")"
BUILD_NUMBER="$(awk -F= '$1=="buildNumber" {print $2}' "$INFO")"
if [[ -n "$PREBUILT_AAB" ]]; then
  [[ -n "$EXPECTED_VERSION" && -n "$EXPECTED_BUILD_NUMBER" ]] ||
    die "prebuilt uploads require --expected-version and --expected-build-number"
else
  EXPECTED_VERSION="${EXPECTED_VERSION:-$VERSION_NAME}"
  EXPECTED_BUILD_NUMBER="${EXPECTED_BUILD_NUMBER:-$BUILD_NUMBER}"
fi
[[ "$EXPECTED_BUILD_NUMBER" =~ ^[0-9]+$ ]] ||
  die "expected build number must be numeric: $EXPECTED_BUILD_NUMBER"
[[ "$VERSION_NAME" == "$EXPECTED_VERSION" ]] ||
  die "build marker version mismatch: $VERSION_NAME != $EXPECTED_VERSION"
[[ "$BUILD_NUMBER" == "$EXPECTED_BUILD_NUMBER" ]] ||
  die "build marker number mismatch: $BUILD_NUMBER != $EXPECTED_BUILD_NUMBER"

UPLOAD_SNAPSHOT="$(mktemp --suffix=.aab)"; TMP_FILES+=("$UPLOAD_SNAPSHOT")
cp -- "$AAB" "$UPLOAD_SNAPSHOT"
[[ "$(sha256sum "$AAB" | awk '{ print $1 }')" == \
   "$(sha256sum "$UPLOAD_SNAPSHOT" | awk '{ print $1 }')" ]] ||
  die "prebuilt AAB changed while creating the upload snapshot"
chmod 400 "$UPLOAD_SNAPSHOT"
AAB_PATH="$UPLOAD_SNAPSHOT"
BUNDLETOOL="$(ensure_bundletool)"
java -jar "$BUNDLETOOL" validate --bundle="$AAB_PATH" >/dev/null ||
  die "prebuilt AAB structure validation failed"
AAB_VERSION_NAME="$(java -jar "$BUNDLETOOL" dump manifest \
  --bundle="$AAB_PATH" --xpath='/manifest/@android:versionName')"
AAB_VERSION_CODE="$(java -jar "$BUNDLETOOL" dump manifest \
  --bundle="$AAB_PATH" --xpath='/manifest/@android:versionCode')"
AAB_PACKAGE="$(java -jar "$BUNDLETOOL" dump manifest \
  --bundle="$AAB_PATH" --xpath='/manifest/@package')"
[[ "$AAB_VERSION_NAME" == "$EXPECTED_VERSION" ]] ||
  die "prebuilt AAB version mismatch: $AAB_VERSION_NAME != $EXPECTED_VERSION"
[[ "$AAB_VERSION_CODE" == "$EXPECTED_BUILD_NUMBER" ]] ||
  die "prebuilt AAB build mismatch: $AAB_VERSION_CODE != $EXPECTED_BUILD_NUMBER"
[[ "$AAB_PACKAGE" == "$PACKAGE_NAME" ]] ||
  die "prebuilt AAB package mismatch: $AAB_PACKAGE != $PACKAGE_NAME"
AAB_SHA256="$(sha256sum "$AAB_PATH" | awk '{ print $1 }')"
if [[ -n "$LISTING_ICON" ]]; then
  [[ -f "$LISTING_ICON" ]] || die "Listing icon not found: $LISTING_ICON"
  [[ "$LISTING_ICON_SHA256" =~ ^[0-9a-fA-F]{64}$ ]] ||
    die "PLAY_LISTING_ICON_SHA256 is required with PLAY_LISTING_ICON"
  [[ "$(sha256sum "$LISTING_ICON" | awk '{ print $1 }')" == "${LISTING_ICON_SHA256,,}" ]] ||
    die "Listing icon does not match its approved SHA-256"
  python3 - "$LISTING_ICON" <<'PY'
from PIL import Image
import pathlib, sys
p = pathlib.Path(sys.argv[1])
with Image.open(p) as image:
    if image.format != "PNG" or image.size != (512, 512):
        raise SystemExit("Listing icon must be a 512x512 PNG")
    if image.mode != "RGB":
        raise SystemExit("Listing icon must be opaque RGB")
PY
fi
RELEASE_NAME="Fractal Forge ${VERSION_NAME:-unknown} (${BUILD_NUMBER:-unknown})"

KEY_FILE="$(mktemp)"; TMP_FILES+=("$KEY_FILE")
python3 - "$KEY_JSON" "$KEY_FILE" <<'PY'
import json, sys
src, dst = sys.argv[1:3]
data = json.load(open(src, encoding='utf-8'))
open(dst, 'w', encoding='utf-8').write(data['private_key'])
PY
CLIENT_EMAIL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["client_email"])' "$KEY_JSON")"
chmod 600 "$KEY_FILE"

NOW="$(date +%s)"
EXP="$((NOW + 3600))"
HEADER='{"alg":"RS256","typ":"JWT"}'
PAYLOAD="$(python3 - <<PY
import json
print(json.dumps({
  'iss': '$CLIENT_EMAIL',
  'scope': 'https://www.googleapis.com/auth/androidpublisher',
  'aud': 'https://oauth2.googleapis.com/token',
  'iat': $NOW,
  'exp': $EXP,
}, separators=(',', ':')))
PY
)"
SIGNING_INPUT="$(printf '%s' "$HEADER" | b64url).$(printf '%s' "$PAYLOAD" | b64url)"
SIGNATURE="$(printf '%s' "$SIGNING_INPUT" | openssl dgst -sha256 -sign "$KEY_FILE" -binary | b64url)"
ASSERTION="$SIGNING_INPUT.$SIGNATURE"

log "Requesting Google access token..."
TOKEN_RESPONSE="$(request -X POST 'https://oauth2.googleapis.com/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
  --data-urlencode "assertion=$ASSERTION")"
ACCESS_TOKEN="$(printf '%s' "$TOKEN_RESPONSE" | json_field access_token)"

API="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$PACKAGE_NAME"
UPLOAD="https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/$PACKAGE_NAME"
AUTH=(-H "Authorization: Bearer $ACCESS_TOKEN")

log "Creating Play edit..."
EDIT_RESPONSE="$(request -X POST "${AUTH[@]}" -H 'Content-Type: application/json' -d '{}' "$API/edits")"
EDIT_ID="$(printf '%s' "$EDIT_RESPONSE" | json_field id)"

log "Uploading verified bundle snapshot for: $AAB"
BUNDLE_RESPONSE="$(request -X POST "${AUTH[@]}" \
  -H 'Content-Type: application/octet-stream' \
  --data-binary "@$AAB_PATH" \
  "$UPLOAD/edits/$EDIT_ID/bundles?uploadType=media")"
VERSION_CODE="$(printf '%s' "$BUNDLE_RESPONSE" | json_field versionCode)"
[[ "$VERSION_CODE" == "$EXPECTED_BUILD_NUMBER" ]] ||
  die "Google Play versionCode mismatch: $VERSION_CODE != $EXPECTED_BUILD_NUMBER"

if [[ -n "$LISTING_ICON" ]]; then
  log "Uploading approved listing icon for locale $LISTING_LOCALE..."
  ICON_RESPONSE="$(request -X POST "${AUTH[@]}" \
    -H 'Content-Type: image/png' \
    --data-binary "@$LISTING_ICON" \
    "$UPLOAD/edits/$EDIT_ID/listings/$LISTING_LOCALE/icon?uploadType=media")"
  ICON_ID="$(printf '%s' "$ICON_RESPONSE" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(data.get("image", data).get("id", ""))')"
  [[ -n "$ICON_ID" ]] || die "Play listing icon upload returned no image ID"
fi

TRACK_BODY="$(mktemp)"; TMP_FILES+=("$TRACK_BODY")
VERSION_CODE="$VERSION_CODE" RELEASE_STATUS="$RELEASE_STATUS" RELEASE_NAME="$RELEASE_NAME" python3 - "$TRACK_BODY" <<'PY'
import json, os, sys
body = {
  'releases': [{
    'name': os.environ['RELEASE_NAME'],
    'versionCodes': [os.environ['VERSION_CODE']],
    'status': os.environ['RELEASE_STATUS'],
  }]
}
open(sys.argv[1], 'w', encoding='utf-8').write(json.dumps(body, separators=(',', ':')))
PY

log "Assigning versionCode $VERSION_CODE to track '$TRACK' as '$RELEASE_STATUS'..."
request -X PUT "${AUTH[@]}" -H 'Content-Type: application/json' --data-binary "@$TRACK_BODY" "$API/edits/$EDIT_ID/tracks/$TRACK" >/dev/null

log "Committing Play edit..."
COMMIT_RESPONSE="$(request -X POST "${AUTH[@]}" "$API/edits/$EDIT_ID:commit")"

log "Verifying committed track and listing icon in a fresh edit..."
VERIFY_EDIT_RESPONSE="$(request -X POST "${AUTH[@]}" -H 'Content-Type: application/json' -d '{}' "$API/edits")"
VERIFY_EDIT_ID="$(printf '%s' "$VERIFY_EDIT_RESPONSE" | json_field id)"
VERIFY_TRACK_RESPONSE="$(request "${AUTH[@]}" "$API/edits/$VERIFY_EDIT_ID/tracks/$TRACK")"
VERIFY_TRACK_RESPONSE="$VERIFY_TRACK_RESPONSE" EXPECTED_BUILD_NUMBER="$EXPECTED_BUILD_NUMBER" RELEASE_STATUS="$RELEASE_STATUS" python3 - <<'PY'
import json, os
track = json.loads(os.environ["VERIFY_TRACK_RESPONSE"])
expected = os.environ["EXPECTED_BUILD_NUMBER"]
status = os.environ["RELEASE_STATUS"]
if not any(expected in [str(v) for v in release.get("versionCodes", [])]
           and release.get("status") == status
           for release in track.get("releases", [])):
    raise SystemExit("Committed Play track does not contain the expected version/status")
PY
if [[ -n "$LISTING_ICON" ]]; then
  VERIFY_ICON_RESPONSE="$(request "${AUTH[@]}" "$API/edits/$VERIFY_EDIT_ID/listings/$LISTING_LOCALE/icon")"
  VERIFY_ICON_RESPONSE="$VERIFY_ICON_RESPONSE" EXPECTED_ICON_ID="$ICON_ID" python3 - <<'PY'
import json, os
images = json.loads(os.environ["VERIFY_ICON_RESPONSE"])
images = images.get("images", images if isinstance(images, list) else [])
if not any(str(image.get("id")) == os.environ["EXPECTED_ICON_ID"] for image in images):
    raise SystemExit("Committed Play listing icon ID was not found in verification edit")
PY
fi
request -X DELETE "${AUTH[@]}" "$API/edits/$VERIFY_EDIT_ID" >/dev/null

RECEIPT_TMP="$(mktemp)"; TMP_FILES+=("$RECEIPT_TMP")
PACKAGE_NAME="$PACKAGE_NAME" EXPECTED_VERSION="$EXPECTED_VERSION" \
EXPECTED_BUILD_NUMBER="$EXPECTED_BUILD_NUMBER" TRACK="$TRACK" \
RELEASE_STATUS="$RELEASE_STATUS" EDIT_ID="$EDIT_ID" \
AAB_SHA256="$AAB_SHA256" LISTING_LOCALE="$LISTING_LOCALE" \
LISTING_ICON_SHA256="$LISTING_ICON_SHA256" ICON_ID="${ICON_ID:-}" \
COMMIT_RESPONSE="$COMMIT_RESPONSE" python3 - "$RECEIPT_TMP" <<'PY'
import datetime, json, os, pathlib, sys
receipt = {
    "package": os.environ["PACKAGE_NAME"],
    "versionName": os.environ["EXPECTED_VERSION"],
    "versionCode": os.environ["EXPECTED_BUILD_NUMBER"],
    "track": os.environ["TRACK"],
    "status": os.environ["RELEASE_STATUS"],
    "publicationEditId": os.environ["EDIT_ID"],
    "commitResponse": json.loads(os.environ["COMMIT_RESPONSE"] or "{}"),
    "postCommitVerified": True,
    "aabSha256": os.environ["AAB_SHA256"],
    "listingLocale": os.environ["LISTING_LOCALE"],
    "listingIconSha256": os.environ["LISTING_ICON_SHA256"],
    "listingIconId": os.environ["ICON_ID"],
    "timestampUtc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
}
pathlib.Path(sys.argv[1]).write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
PY
mkdir -p "$(dirname "$RECEIPT_PATH")"
mv "$RECEIPT_TMP" "$RECEIPT_PATH"
log "Upload complete: $PACKAGE_NAME versionCode $VERSION_CODE -> $TRACK ($RELEASE_STATUS); receipt: $RECEIPT_PATH"
