#!/usr/bin/env bash
# Check that a published Play release is live, propagated and (optionally)
# approved. Reusable in CI, cron or a release record.
#
# It runs play-observe.sh when no observation is supplied, then applies policy:
#   - the production track release is completed and carries the expected code
#   - enough probed storefronts list the app, with no probe transport errors
#   - every probed storefront shows the expected version/date (unless relaxed)
#   - the Play Console review state is acceptable (only when requested)
#
# Review has no official API. --require-review evaluates a Console state that
# play-observe.sh collected from --console-html/--console-url. Without that
# input the check records the inference and does not claim review.
#
# Usage: scripts/ci/play-live-check.sh [options]
#   --input FILE             evaluate a saved play-observe JSON (no network)
#   --expected-version X.Y.Z required unless --input carries it
#   --expected-date "Nov 6, 2026"  storefront "Updated on" value to match
#   --countries US,GB,...    storefronts to probe (observer default otherwise)
#   --min-available N        minimum listed storefronts (default: all probed)
#   --allow-pending          tolerate storefronts that still show an older build
#   --require-review STATE   fail unless the Console state is approved/published
#   --console-html FILE      saved Play Console publishing page
#   --console-url URL        live Play Console page (needs --console-cookies)
#   --console-cookies FILE   Netscape cookie file (never printed)
#   --output FILE            write the check JSON
#   --json                   emit JSON (default)
#   --help
#
# Exit codes: 0 pass, 1 a check failed, 2 bad input or prerequisites.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die() { echo "[play-live-check] ERROR: $*" >&2; exit 2; }

INPUT=""
EXPECTED_VERSION=""
EXPECTED_DATE=""
COUNTRIES=""
MIN_AVAILABLE=""
ALLOW_PENDING=0
REQUIRE_REVIEW=""
OUTPUT=""
CONSOLE_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) [[ $# -ge 2 ]] || die "--input requires a value"; INPUT="$2"; shift 2 ;;
    --input=*) INPUT="${1#*=}"; shift ;;
    --expected-version) [[ $# -ge 2 ]] || die "--expected-version requires a value"; EXPECTED_VERSION="$2"; shift 2 ;;
    --expected-version=*) EXPECTED_VERSION="${1#*=}"; shift ;;
    --expected-date) [[ $# -ge 2 ]] || die "--expected-date requires a value"; EXPECTED_DATE="$2"; shift 2 ;;
    --expected-date=*) EXPECTED_DATE="${1#*=}"; shift ;;
    --countries) [[ $# -ge 2 ]] || die "--countries requires a value"; COUNTRIES="$2"; shift 2 ;;
    --countries=*) COUNTRIES="${1#*=}"; shift ;;
    --min-available) [[ $# -ge 2 ]] || die "--min-available requires a value"; MIN_AVAILABLE="$2"; shift 2 ;;
    --min-available=*) MIN_AVAILABLE="${1#*=}"; shift ;;
    --allow-pending) ALLOW_PENDING=1; shift ;;
    --require-review) [[ $# -ge 2 ]] || die "--require-review requires a value"; REQUIRE_REVIEW="$2"; shift 2 ;;
    --require-review=*) REQUIRE_REVIEW="${1#*=}"; shift ;;
    --console-html) [[ $# -ge 2 ]] || die "--console-html requires a value"; CONSOLE_ARGS+=(--console-html "$2"); shift 2 ;;
    --console-html=*) CONSOLE_ARGS+=(--console-html "${1#*=}"); shift ;;
    --console-url) [[ $# -ge 2 ]] || die "--console-url requires a value"; CONSOLE_ARGS+=(--console-url "$2"); shift 2 ;;
    --console-url=*) CONSOLE_ARGS+=(--console-url "${1#*=}"); shift ;;
    --console-cookies) [[ $# -ge 2 ]] || die "--console-cookies requires a value"; CONSOLE_ARGS+=(--console-cookies "$2"); shift 2 ;;
    --console-cookies=*) CONSOLE_ARGS+=(--console-cookies "${1#*=}"); shift ;;
    --output) [[ $# -ge 2 ]] || die "--output requires a value"; OUTPUT="$2"; shift 2 ;;
    --output=*) OUTPUT="${1#*=}"; shift ;;
    --json) shift ;;
    --help|-h) sed -n '2,32p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT

if [[ -z "$INPUT" ]]; then
  [[ -n "$EXPECTED_VERSION" ]] || die "--expected-version is required when no --input is given"
  observe=(--expected-version "$EXPECTED_VERSION" --output "$work/observed.json" "${CONSOLE_ARGS[@]}")
  [[ -n "$EXPECTED_DATE" ]] && observe+=(--expected-date "$EXPECTED_DATE")
  [[ -n "$COUNTRIES" ]] && observe+=(--countries "$COUNTRIES")
  if ! bash "$SCRIPT_DIR/play-observe.sh" "${observe[@]}" >/dev/null 2>"$work/observe.err"; then
    cat "$work/observe.err" >&2
    die "observation failed"
  fi
  INPUT="$work/observed.json"
fi
[[ -f "$INPUT" ]] || die "observation file not found: $INPUT"

result="$(python3 - "$INPUT" "$EXPECTED_VERSION" "$EXPECTED_DATE" "$MIN_AVAILABLE" "$ALLOW_PENDING" "$REQUIRE_REVIEW" <<'PY'
import json, sys

path, expected_version, expected_date, min_available, allow_pending, require_review = sys.argv[1:7]
with open(path, encoding="utf-8") as handle:
    observed = json.load(handle)

expected_version = expected_version or (observed.get("expected_version") or "")
expected_date = expected_date or (observed.get("expected_updated") or "")
allow_pending = allow_pending == "1"

checks = {}
reasons = []

releases = observed.get("official", {}).get("track", {}).get("releases", [])
release = releases[0] if releases else {}
status = release.get("status")
codes = [str(code) for code in release.get("versionCodes", [])]
checks["track_completed"] = {"passed": status == "completed", "observed": status}
if status != "completed":
    reasons.append(f"track status is {status!r}, expected 'completed'")

if expected_version:
    expected_code = expected_version.rsplit(".", 1)[-1]
    version_on_track = expected_version in codes or expected_code in codes
    checks["version_code"] = {
        "passed": version_on_track,
        "expected": expected_version,
        "expected_code": expected_code,
        "observed": codes,
    }
    if not version_on_track:
        reasons.append(f"version {expected_version} (code {expected_code}) is not on the track ({codes})")

summary = observed.get("storefront", {}).get("summary", {})
probed = summary.get("probed", 0)
available = summary.get("available", 0)
unavailable = summary.get("unavailable", [])
errors = summary.get("errors", [])
pending = summary.get("pending", [])
try:
    minimum = int(min_available) if min_available else probed
except ValueError:
    minimum = probed

checks["storefront_available"] = {
    "passed": probed > 0 and available >= minimum and not errors,
    "probed": probed,
    "available": available,
    "minimum": minimum,
    "unavailable": unavailable,
    "errors": errors,
}
if probed == 0:
    reasons.append("no storefront was probed")
if available < minimum:
    reasons.append(f"only {available}/{probed} storefronts list the app (minimum {minimum})")
if errors:
    reasons.append(f"storefront probe errors: {errors}")

checks["propagation"] = {
    "passed": allow_pending or not pending,
    "pending": pending,
    "expected_version": expected_version or None,
    "expected_updated": expected_date or None,
}
if pending and not allow_pending:
    reasons.append(f"storefronts still show an older build: {[item.get('country') for item in pending]}")

review = observed.get("review", {})
console = review.get("console") or {}
console_state = console.get("state")
if require_review:
    good = console_state in {"approved", "published"}
    checks["review"] = {
        "passed": good,
        "required": require_review,
        "observed": console_state or "missing",
    }
    if console_state is None:
        reasons.append("review was required but no Console state was supplied")
    elif not good:
        reasons.append(f"Console review state is {console_state!r}")

passed = all(check["passed"] for check in checks.values())
document = {
    "status": "pass" if passed else "fail",
    "checks": checks,
    "reasons": reasons,
    "review_inference": (review.get("inferred_from_storefront") or {}).get("state"),
    "console_review_state": console_state,
    "observed_at_utc": observed.get("observed_at_utc"),
    "input": path,
    "package": observed.get("package"),
    "expected_version": expected_version or None,
    "expected_updated": expected_date or None,
}
print(json.dumps(document, indent=2, sort_keys=True))
sys.exit(0 if passed else 1)
PY
)" || status=$?
status="${status:-0}"
[[ -n "$OUTPUT" ]] && printf '%s\n' "$result" > "$OUTPUT"
printf '%s\n' "$result"
python3 - "$result" <<'PY' >&2
import json, sys
d = json.loads(sys.argv[1])
print(f"[play-live-check] {d['status'].upper()} package={d['package']} version={d['expected_version']}")
for name, check in d["checks"].items():
    print(f"  {'PASS' if check['passed'] else 'FAIL'} {name}: "
          f"{ {k: v for k, v in check.items() if k != 'passed'} }")
for reason in d["reasons"]:
    print(f"  reason: {reason}")
if d.get("console_review_state") is None:
    print("  review: no Console state supplied; inference only")
PY
exit "$status"
