#!/usr/bin/env bash
set -euo pipefail

# Capture deterministic screenshots using Flutter desktop (Linux) integration_test.
#
# Why: avoids Android emulator / system image downloads.
#
# Usage:
#   ./scripts/desktop-screenshots.sh
#
# Output:
#   ./screenshots/ (direct captures, with build/ fallback)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Exported because the xvfb-run branch re-declares run_flutter_test in a fresh
# login shell; unexported vars arrive empty there, and `flutter test ""` sweeps
# the whole suite instead of this one file.
export DEVICE_ID="${DEVICE_ID:-linux}"
export TEST_FILE="${TEST_FILE:-integration_test/screenshots/full_screenshots_test.dart}"
export ROOT_DIR
OUT_DIR="${OUT_DIR:-$ROOT_DIR/screenshots}"

mkdir -p "$OUT_DIR"

# Without FORCE_GPU_RENDER the renderer swaps in its placeholder surface for any
# test binding -- a plain black ColoredBox -- so every viewer screenshot comes
# out black with only the chrome visible. See RuntimeModeService.
run_flutter_test() {
  cd "$ROOT_DIR"
  flutter test "$TEST_FILE" -d "$DEVICE_ID" --reporter expanded \
    --dart-define=FORCE_GPU_RENDER=true
}

# Keep the suite's existing filename convention, not arbitrary build assets.
# Direct producer output wins; build fallbacks are ordered lexically for ties.
capture_paths() {
  if [[ -d screenshots ]]; then
    find screenshots -maxdepth 1 -type f \( -name '0*.png' -o -name '1*_*.png' \) -print0 | LC_ALL=C sort -z
  fi
  if [[ -d build ]]; then
    find build -type f \( -name '0*.png' -o -name '1*_*.png' \) -print0 | LC_ALL=C sort -z
  fi
}

# Compare file identity and nanosecond metadata, not wall-clock cutoffs: quick
# rewrites (even with identical bytes) count, unchanged previous outputs do not.
declare -A before=()
while IFS= read -r -d '' f; do
  before["$f"]="$(stat -c '%d:%i:%s:%y:%z' -- "$f")"
done < <(capture_paths)

echo "[desktop-screenshots] device=$DEVICE_ID test=$TEST_FILE"

if command -v xvfb-run >/dev/null 2>&1; then
  echo "[desktop-screenshots] Using xvfb-run (headless)"
  xvfb-run -a -s "-screen 0 1080x1920x24" bash -lc "$(declare -f run_flutter_test); run_flutter_test"
else
  echo "[desktop-screenshots] xvfb-run not found; running with a real desktop session"
  run_flutter_test
fi

declare -A chosen=()
current=()
while IFS= read -r -d '' f; do
  signature="$(stat -c '%d:%i:%s:%y:%z' -- "$f")"
  [[ "${before["$f"]:-}" != "$signature" ]] || continue
  base="${f##*/}"
  if [[ -n "${chosen["$base"]:-}" ]]; then
    echo "[desktop-screenshots] Duplicate $base: keeping ${chosen["$base"]}; ignoring $f"
    continue
  fi
  chosen["$base"]="$f"
  current+=("$f")
done < <(capture_paths)

if [[ ${#current[@]} == 0 ]]; then
  echo "[desktop-screenshots] ERROR: No new suite screenshots in ./screenshots or ./build"
  echo "  Check test output for 'SCREENSHOT' lines and capture failures."
  exit 2
fi

for f in "${current[@]}"; do
  destination="$OUT_DIR/${f##*/}"
  # The desktop producer already writes to the default output directory.
  if [[ ! "$f" -ef "$destination" ]]; then
    cp -f -- "$f" "$destination"
  fi
  printf '[desktop-screenshots] Collected: %s (source: %s)\n' "$destination" "$f"
done

echo "[desktop-screenshots] Done. Collected ${#current[@]} screenshot(s) in $OUT_DIR"
