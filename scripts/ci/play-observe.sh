#!/usr/bin/env bash
# Observe what Play publishes and where end users can see it. Read-only.
#
# Combines two sources:
#   1. The official Play Developer API (same read-only edit pattern as
#      play-status.sh): track release, country availability, app details.
#   2. Public storefront pages per country: availability, "Updated on" date and
#      the embedded version when the page exposes it.
#
# Google app-review status has no public API. This script records that limit; it
# reports the release/track state and the storefront result, not an approval.
#
# Usage: scripts/ci/play-observe.sh [options]
#   --countries US,GB,...     storefronts to probe (default: targeted countries,
#                             first 12 with US first; fallback US,GB,CA,DE,FR,ES,
#                             MX,BR,IN,JP,AU)
#   --expected-version X.Y.Z  default: versionName in fdroid/version.properties
#   --expected-date "Nov 6, 2026"  storefront "Updated on" value to match
#   --lang en                 storefront language
#   --output FILE             also write the JSON document to FILE
#   --json                    emit JSON to stdout (default)
#   --help
#
# Exit codes: 0 observation produced, 2 prerequisites or arguments missing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/play-api.sh"

COUNTRIES=""
EXPECTED_VERSION=""
EXPECTED_DATE=""
LANG_CODE="en"
OUTPUT=""

die() { echo "[play-observe] ERROR: $*" >&2; exit 2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --countries) [[ $# -ge 2 ]] || die "--countries requires a value"; COUNTRIES="$2"; shift 2 ;;
    --countries=*) COUNTRIES="${1#*=}"; shift ;;
    --expected-version) [[ $# -ge 2 ]] || die "--expected-version requires a value"; EXPECTED_VERSION="$2"; shift 2 ;;
    --expected-version=*) EXPECTED_VERSION="${1#*=}"; shift ;;
    --expected-date) [[ $# -ge 2 ]] || die "--expected-date requires a value"; EXPECTED_DATE="$2"; shift 2 ;;
    --expected-date=*) EXPECTED_DATE="${1#*=}"; shift ;;
    --lang) [[ $# -ge 2 ]] || die "--lang requires a value"; LANG_CODE="$2"; shift 2 ;;
    --lang=*) LANG_CODE="${1#*=}"; shift ;;
    --output) [[ $# -ge 2 ]] || die "--output requires a value"; OUTPUT="$2"; shift 2 ;;
    --output=*) OUTPUT="${1#*=}"; shift ;;
    --json) shift ;;
    --help|-h) sed -n '2,30p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ -n "$EXPECTED_VERSION" ]] || EXPECTED_VERSION="$(awk -F= '/^versionName=/{print $2}' "$ROOT/fdroid/version.properties" 2>/dev/null || true)"

token="$(play_access_token)" || die "could not obtain a Play access token"
edit="$(play_open_edit "$token")" || die "could not open a Play edit"
cleanup() { play_discard_edit "${token:-}" "${edit:-}"; }
trap cleanup EXIT

TRACK="$(play_track)"
work="$(mktemp -d)"; trap 'cleanup; rm -rf "$work"' EXIT

play_get "$token" "$edit" "/tracks/$TRACK" > "$work/track.json" || die "could not read track $TRACK"
play_get "$token" "$edit" "/countryAvailability/$TRACK" > "$work/availability.json" || die "could not read country availability for $TRACK"
play_get "$token" "$edit" "/details" > "$work/details.json" || die "could not read app details"

if [[ -z "$COUNTRIES" ]]; then
  COUNTRIES="$(python3 - "$work/availability.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
codes = [entry.get("countryCode", "") for entry in data.get("countries", [])]
codes = sorted({code for code in codes if code and code != "US"})
selection = ["US", *codes]
print(",".join(selection[:12]) if selection else "US,GB,CA,DE,FR,ES,MX,BR,IN,JP,AU")
PY
)"
fi

PACKAGE="$(play_package_name)"
probe_args=(--package "$PACKAGE" --countries "$COUNTRIES" --lang "$LANG_CODE")
if [[ -n "$EXPECTED_VERSION" ]]; then probe_args+=(--expected-version "$EXPECTED_VERSION"); fi
if [[ -n "$EXPECTED_DATE" ]]; then probe_args+=(--expected-date "$EXPECTED_DATE"); fi
python3 "$SCRIPT_DIR/play_storefront.py" "${probe_args[@]}" > "$work/storefront.json"

python3 - "$work" "$PACKAGE" "$TRACK" "$EXPECTED_VERSION" "$EXPECTED_DATE" <<'PY' > "$work/observed.json"
import datetime, json, pathlib, sys
work, package, track, expected_version, expected_date = sys.argv[1:6]
read = lambda name: json.load(open(pathlib.Path(work) / name, encoding="utf-8"))
document = {
    "package": package,
    "track": track,
    "expected_version": expected_version or None,
    "expected_updated": expected_date or None,
    "observed_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
    "official": {
        "track": read("track.json"),
        "country_availability": read("availability.json"),
        "details": read("details.json"),
    },
    "storefront": read("storefront.json"),
    "review": {
        "status": "not-observable",
        "reason": "Google Play app review has no public Developer API endpoint",
        "practical_signals": [
            "Play Console > Publishing overview shows changes in review",
            "the developer account receives Google review email",
            "the storefront lists the release date after approval and propagation",
            "the track release status is rollout state, not review state",
        ],
    },
}
print(json.dumps(document, indent=2, sort_keys=True))
PY

cat "$work/observed.json"
[[ -n "$OUTPUT" ]] && cp "$work/observed.json" "$OUTPUT"
python3 - "$work/observed.json" <<'PY' >&2
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
s = d["storefront"]["summary"]
releases = d["official"]["track"].get("releases", [])
codes = releases[0].get("versionCodes") if releases else None
status = releases[0].get("status") if releases else None
print(f"[play-observe] track={d['track']} status={status} versionCodes={codes}")
print(f"[play-observe] expected_version={d['expected_version']} expected_updated={d['expected_updated']}")
print(f"[play-observe] storefront probed={s['probed']} available={s['available']} "
      f"propagated={len(s['propagated'])} pending={len(s['pending'])} "
      f"unavailable={len(s['unavailable'])} errors={len(s['errors'])}")
if s["pending"]:
    print(f"[play-observe] pending: {s['pending']}")
if s["errors"]:
    print(f"[play-observe] probe errors: {s['errors']}")
print("[play-observe] review status: not observable through the public API")
PY
