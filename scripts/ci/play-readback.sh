#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/ci/play-api.sh
. "$SCRIPT_DIR/play-api.sh"

TRACK="${PLAY_TRACK:-production}"
RELEASE_STATUS="${PLAY_RELEASE_STATUS:-completed}"
EXPECTED_BUILD_NUMBER="${1:?expected build number required}"
EXPECTED_SHA256="${2:?expected AAB SHA-256 required}"
EDIT_ID=""
ACCESS_TOKEN=""
cleanup() {
  play_discard_edit "$ACCESS_TOKEN" "$EDIT_ID"
}
trap cleanup EXIT

[[ "$EXPECTED_BUILD_NUMBER" =~ ^[0-9]+$ && "$EXPECTED_SHA256" =~ ^[0-9a-fA-F]{64}$ ]] || {
  echo "Invalid Play readback identity" >&2; exit 2;
}

ACCESS_TOKEN="$(play_access_token)" || exit 2
[[ -n "$ACCESS_TOKEN" ]] || { echo "empty Play access token" >&2; exit 2; }
EDIT_ID="$(play_open_edit "$ACCESS_TOKEN")" || { echo "could not open a Play edit" >&2; exit 2; }
TRACK_RESPONSE="$(play_get "$ACCESS_TOKEN" "$EDIT_ID" "/tracks/$TRACK")"
BUNDLES_RESPONSE="$(play_get "$ACCESS_TOKEN" "$EDIT_ID" "/bundles")"
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
play_discard_edit "$ACCESS_TOKEN" "$EDIT_ID"
EDIT_ID=""
