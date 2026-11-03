#!/usr/bin/env bash
# Read-only Google Play status: what the store currently serves and which AAB
# version codes are already consumed.
#
# Usage: scripts/ci/play-status.sh [--track TRACK] [--pretty]
#
# Output (default JSON, one line):
#   {"package":…,"track":…,"releases":[…],"trackVersionCodes":[…],
#    "latestVersionCode":N,"uploadedVersionCodes":[…],"bundleSha256":{…}}
#
# This command never uploads, never commits and never changes a listing. It
# opens one throwaway edit to read the track/bundles and deletes it again, so
# it is safe to run before deciding a release identity or after an uncertain
# upload. Missing credentials exit 2; a failing API call exits 1.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci/play-api.sh
. "$SCRIPT_DIR/play-api.sh"

TRACK="${PLAY_TRACK:-production}"
PRETTY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --track) [[ $# -ge 2 ]] || { echo "--track requires a value" >&2; exit 2; }; TRACK="$2"; shift 2 ;;
    --track=*) TRACK="${1#*=}"; shift ;;
    --pretty) PRETTY=1; shift ;;
    --help|-h) sed -n '2,14p' "$SCRIPT_DIR/play-status.sh" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

TOKEN="$(play_access_token)" || exit 2
[[ -n "$TOKEN" ]] || { echo "empty Play access token" >&2; exit 2; }
EDIT="$(play_open_edit "$TOKEN")" || { echo "could not open a Play edit" >&2; exit 1; }
trap 'play_discard_edit "$TOKEN" "$EDIT"' EXIT

TRACK_RESPONSE="$(play_get "$TOKEN" "$EDIT" "/tracks/$TRACK")" || {
  echo "could not read the Play track '$TRACK'" >&2
  exit 1
}
BUNDLES_RESPONSE="$(play_get "$TOKEN" "$EDIT" "/bundles")" || {
  echo "could not read uploaded Play bundles" >&2
  exit 1
}

PLAY_TRACK_RESPONSE="$TRACK_RESPONSE" PLAY_BUNDLES_RESPONSE="$BUNDLES_RESPONSE" \
  PACKAGE_NAME="$(play_package_name)" TRACK="$TRACK" PRETTY="$PRETTY" python3 - <<'PY'
import json, os, sys

track = json.loads(os.environ["PLAY_TRACK_RESPONSE"])
bundles = json.loads(os.environ["PLAY_BUNDLES_RESPONSE"]).get("bundles", [])
releases = [
    {"name": release.get("name", ""),
     "versionCodes": [str(code) for code in release.get("versionCodes", [])],
     "status": release.get("status", "")}
    for release in track.get("releases", [])
]
track_codes = [code for release in releases for code in release["versionCodes"]]
uploaded = sorted(int(bundle["versionCode"]) for bundle in bundles
                  if str(bundle.get("versionCode", "")).isdigit())
payload = {
    "package": os.environ["PACKAGE_NAME"],
    "track": os.environ["TRACK"],
    "releases": releases,
    "trackVersionCodes": track_codes,
    "latestVersionCode": uploaded[-1] if uploaded else 0,
    "uploadedVersionCodes": uploaded,
    "bundleSha256": {str(bundle["versionCode"]): bundle.get("sha256", "")
                     for bundle in bundles},
}
if os.environ["PRETTY"] == "1":
    print(f"{payload['package']}  track={payload['track']}")
    for release in releases:
        print(f"  release  {', '.join(release['versionCodes']):>10}  "
              f"{release['status']:<10} {release['name']}")
    print(f"  latest consumed version code: {payload['latestVersionCode']}")
    print(f"  uploaded bundles: {', '.join(str(code) for code in uploaded)}")
else:
    print(json.dumps(payload, sort_keys=True))
PY
