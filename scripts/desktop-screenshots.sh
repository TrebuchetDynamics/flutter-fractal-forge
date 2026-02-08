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
#   ./screenshots/ (copied from build/…)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DEVICE_ID="${DEVICE_ID:-linux}"
TEST_FILE="${TEST_FILE:-integration_test/screenshots_test.dart}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/screenshots}"

mkdir -p "$OUT_DIR"

run_flutter_test() {
  flutter test "$TEST_FILE" -d "$DEVICE_ID" --reporter expanded
}

echo "[desktop-screenshots] device=$DEVICE_ID test=$TEST_FILE"

if command -v xvfb-run >/dev/null 2>&1; then
  echo "[desktop-screenshots] Using xvfb-run (headless)"
  xvfb-run -a -s "-screen 0 1080x1920x24" bash -lc "$(declare -f run_flutter_test); run_flutter_test"
else
  echo "[desktop-screenshots] xvfb-run not found; running with a real desktop session"
  run_flutter_test
fi

# Flutter versions differ slightly on where screenshots are written.
CANDIDATES=(
  "build/integration_test/screenshots"
  "build/integration_test" 
  "build" 
)

SRC=""
for c in "${CANDIDATES[@]}"; do
  if compgen -G "$c/*.png" > /dev/null; then
    SRC="$c"
    break
  fi
  if compgen -G "$c/**/screenshots/*.png" > /dev/null; then
    # shellcheck disable=SC2164
    SRC="$c"
    break
  fi
done

echo "[desktop-screenshots] Locating PNGs in build/..."
PNGS=$(find build -type f -name '*.png' | wc -l | tr -d ' ')
if [[ "$PNGS" == "0" ]]; then
  echo "[desktop-screenshots] ERROR: No PNGs found under ./build"
  echo "  Check test output for 'SCREENSHOT:' lines."
  exit 2
fi

echo "[desktop-screenshots] Copying PNGs to $OUT_DIR"
find build -type f -name '*.png' -print0 | while IFS= read -r -d '' f; do
  base=$(basename "$f")
  # Only keep screenshots from this suite.
  if [[ "$base" == 0*_*.png || "$base" == 0*.png || "$base" == 1*_*.png ]]; then
    cp -f "$f" "$OUT_DIR/$base"
  fi
done

echo "[desktop-screenshots] Done. Output files:"
ls -la "$OUT_DIR" | sed -n '1,200p'
