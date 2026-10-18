#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="${PLAY_PACKAGE_NAME:-com.trebuchetdynamics.fractal.forge}"
KEY_JSON="${PLAY_SERVICE_ACCOUNT_JSON:-play-console-upload/play-service-account.json}"
TRACK="${PLAY_TRACK:-production}"
RELEASE_STATUS="${PLAY_RELEASE_STATUS:-completed}"
EXPECTED_BUILD_NUMBER="${1:?expected build number required}"
EXPECTED_SHA256="${2:?expected AAB SHA-256 required}"
TMP_FILES=()
EDIT_ID=""
ACCESS_TOKEN=""
API=""
cleanup() {
  if [[ -n "$EDIT_ID" && -n "$ACCESS_TOKEN" && -n "$API" ]]; then
    curl -fsS -X DELETE -H "Authorization: Bearer $ACCESS_TOKEN" "$API/edits/$EDIT_ID" >/dev/null 2>&1 || true
  fi
  rm -f "${TMP_FILES[@]:-}"
}
trap cleanup EXIT

[[ -f "$KEY_JSON" ]] || { echo "Play service account JSON unavailable" >&2; exit 2; }
[[ "$EXPECTED_BUILD_NUMBER" =~ ^[0-9]+$ && "$EXPECTED_SHA256" =~ ^[0-9a-fA-F]{64}$ ]] || {
  echo "Invalid Play readback identity" >&2; exit 2;
}
for tool in curl openssl python3; do command -v "$tool" >/dev/null || { echo "$tool unavailable" >&2; exit 2; }; done

KEY_FILE="$(mktemp)"
TMP_FILES+=("$KEY_FILE")
python3 - "$KEY_JSON" "$KEY_FILE" <<'PY'
import json, pathlib, sys
source, target = sys.argv[1:3]
pathlib.Path(target).write_text(json.load(open(source, encoding="utf-8"))["private_key"])
PY
chmod 600 "$KEY_FILE"
CLIENT_EMAIL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8")).get("client_email", ""))' "$KEY_JSON")"
[[ -n "$CLIENT_EMAIL" ]] || { echo "Play service account email missing" >&2; exit 2; }
NOW="$(date +%s)"
HEADER="$(printf '%s' '{"alg":"RS256","typ":"JWT"}' | openssl base64 -A | tr '+/' '-_' | tr -d '=')"
PAYLOAD="$(CLIENT_EMAIL="$CLIENT_EMAIL" NOW="$NOW" python3 - <<'PY'
import base64, json, os
body = {"iss": os.environ["CLIENT_EMAIL"], "scope": "https://www.googleapis.com/auth/androidpublisher",
        "aud": "https://oauth2.googleapis.com/token", "iat": int(os.environ["NOW"]),
        "exp": int(os.environ["NOW"]) + 3600}
print(base64.urlsafe_b64encode(json.dumps(body, separators=(",", ":")).encode()).decode().rstrip("="))
PY
)"
SIGNING_INPUT="$HEADER.$PAYLOAD"
SIGNATURE="$(printf '%s' "$SIGNING_INPUT" | openssl dgst -sha256 -sign "$KEY_FILE" -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=')"
ASSERTION="$SIGNING_INPUT.$SIGNATURE"
TOKEN_RESPONSE="$(curl -fsS -X POST 'https://oauth2.googleapis.com/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
  --data-urlencode "assertion=$ASSERTION")"
ACCESS_TOKEN="$(printf '%s' "$TOKEN_RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')"
API="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$PACKAGE_NAME"
AUTH=(-H "Authorization: Bearer $ACCESS_TOKEN")
EDIT_RESPONSE="$(curl -fsS -X POST "${AUTH[@]}" -H 'Content-Type: application/json' -d '{}' "$API/edits")"
EDIT_ID="$(printf '%s' "$EDIT_RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"
TRACK_RESPONSE="$(curl -fsS "${AUTH[@]}" "$API/edits/$EDIT_ID/tracks/$TRACK")"
BUNDLES_RESPONSE="$(curl -fsS "${AUTH[@]}" "$API/edits/$EDIT_ID/bundles")"
PLAY_TRACK_RESPONSE="$TRACK_RESPONSE" PLAY_BUNDLES_RESPONSE="$BUNDLES_RESPONSE" \
  EXPECTED_BUILD_NUMBER="$EXPECTED_BUILD_NUMBER" EXPECTED_SHA256="${EXPECTED_SHA256,,}" \
  TRACK="$TRACK" RELEASE_STATUS="$RELEASE_STATUS" python3 - <<'PY'
import base64, hashlib, json, os
track = json.loads(os.environ["PLAY_TRACK_RESPONSE"])
bundles = json.loads(os.environ["PLAY_BUNDLES_RESPONSE"]).get("bundles", [])
version = os.environ["EXPECTED_BUILD_NUMBER"]
status = os.environ["RELEASE_STATUS"]
raw_hash = bytes.fromhex(os.environ["EXPECTED_SHA256"])
accepted_hashes = {raw_hash.hex(), base64.b64encode(raw_hash).decode(),
                   base64.urlsafe_b64encode(raw_hash).decode().rstrip("=")}
releases = track.get("releases", [])
track_has_version = any(version in [str(code) for code in release.get("versionCodes", [])]
                       for release in releases)
release_matches = any(version in [str(code) for code in release.get("versionCodes", [])]
                      and release.get("status") == status for release in releases)
bundles_have_version = any(str(bundle.get("versionCode")) == version for bundle in bundles)
bundle_matches = any(str(bundle.get("versionCode")) == version
                     and bundle.get("sha256", "").rstrip("=") in {item.rstrip("=") for item in accepted_hashes}
                     for bundle in bundles)
found = release_matches and bundle_matches
print(json.dumps({"found": found, "conflict": (track_has_version or bundles_have_version) and not found,
                  "versionCode": version, "track": os.environ["TRACK"], "status": status,
                  "aabSha256": os.environ["EXPECTED_SHA256"]}))
PY
curl -fsS -X DELETE "${AUTH[@]}" "$API/edits/$EDIT_ID" >/dev/null
EDIT_ID=""
