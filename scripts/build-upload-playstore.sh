#!/usr/bin/env bash
set -euo pipefail

# Build signed AAB, then upload it to Google Play via Android Publisher API.
# No Ruby/Fastlane.
# Usage:
#   ./build-upload-playstore.sh [scripts/build-play-console.sh args...]
# Env:
#   PLAY_TRACK=internal|alpha|beta|production   default: production
#   PLAY_RELEASE_STATUS=completed|draft        default: completed
#   PLAY_SERVICE_ACCOUNT_JSON=path             default: play-console-upload/play-service-account.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

PACKAGE_NAME="${PLAY_PACKAGE_NAME:-com.trebuchetdynamics.fractal.forge}"
TRACK="${PLAY_TRACK:-production}"
RELEASE_STATUS="${PLAY_RELEASE_STATUS:-completed}"
KEY_JSON="${PLAY_SERVICE_ACCOUNT_JSON:-play-console-upload/play-service-account.json}"
TMP_FILES=()

log() { echo "[build-upload-playstore] $*"; }
die() { echo "[build-upload-playstore] ERROR: $*" >&2; exit 1; }
usage() {
  sed -n '3,12p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'
  echo
  scripts/build-play-console.sh --help
}
cleanup() { rm -f "${TMP_FILES[@]:-}"; }
trap cleanup EXIT

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found"; }
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
need openssl
need python3

scripts/build-play-console.sh "$@"

AAB="$(tr -d '\r\n' < play-console-upload/LATEST_AAB.txt)"
[[ -f "$AAB" ]] || die "Built AAB not found: $AAB"

INFO="play-console-upload/LATEST_BUILD_INFO.txt"
VERSION_NAME="$(awk -F= '$1=="versionName" {print $2}' "$INFO")"
BUILD_NUMBER="$(awk -F= '$1=="buildNumber" {print $2}' "$INFO")"
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

log "Uploading bundle: $AAB"
BUNDLE_RESPONSE="$(request -X POST "${AUTH[@]}" \
  -H 'Content-Type: application/octet-stream' \
  --data-binary "@$AAB" \
  "$UPLOAD/edits/$EDIT_ID/bundles?uploadType=media")"
VERSION_CODE="$(printf '%s' "$BUNDLE_RESPONSE" | json_field versionCode)"

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
