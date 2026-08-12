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
request -X POST "${AUTH[@]}" "$API/edits/$EDIT_ID:commit" >/dev/null

log "Upload complete: $PACKAGE_NAME versionCode $VERSION_CODE -> $TRACK ($RELEASE_STATUS)"
