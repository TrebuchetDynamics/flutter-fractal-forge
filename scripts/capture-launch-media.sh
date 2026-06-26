#!/usr/bin/env bash
#
# Capture high-resolution marketing stills of the Featured Launch Set.
#
# Renders kFeaturedLaunchSetModuleIds (lib/features/catalog/featured_launch_set.dart)
# through the GPU thumbnail harness at LAUNCH_MEDIA_SIZE resolution, into
# build/test_output/launch_media/.
#
# Run on a machine with a REAL GPU for launch-quality output. Headless/xvfb
# falls back to software GL, which is fine for a smoke but not for final assets
# (see docs/planning/LAUNCH_LADDER.md).
#
# Usage:
#   ./scripts/capture-launch-media.sh                 # 1080px, full featured set
#   LAUNCH_MEDIA_SIZE=1440 ./scripts/capture-launch-media.sh
#   CATALOG_THUMB_ONLY=mandelbulb,spectre_monotile ./scripts/capture-launch-media.sh
#   CATALOG_THUMB_SEED=launch-2 ./scripts/capture-launch-media.sh   # vary palettes
set -euo pipefail
cd "$(dirname "$0")/.."

SIZE="${LAUNCH_MEDIA_SIZE:-1080}"
DEVICE="${DEVICE_ID:-linux}"
SEED="${CATALOG_THUMB_SEED:-launch-media-v1}"
ONLY="${CATALOG_THUMB_ONLY:-}"
TEST="integration_test/catalog/generate_gpu_thumbnails_test.dart"
OUT="build/test_output/launch_media"

echo "==> Featured Launch Set capture @ ${SIZE}x${SIZE} (device=$DEVICE, seed=$SEED)"
[[ -n "$ONLY" ]] && echo "    filter: $ONLY"

env_vars=(LAUNCH_MEDIA_SIZE="$SIZE" CATALOG_THUMB_SEED="$SEED")
[[ -n "$ONLY" ]] && env_vars+=(CATALOG_THUMB_ONLY="$ONLY")
cmd=(flutter test "$TEST" -d "$DEVICE" --reporter expanded)

if [[ "$DEVICE" == "linux" && -z "${DISPLAY:-}" ]]; then
  echo "    (headless: xvfb + software GL — use a real GPU display for final assets)"
  env "${env_vars[@]}" xvfb-run -a -s "-screen 0 ${SIZE}x${SIZE}x24" "${cmd[@]}"
else
  env "${env_vars[@]}" "${cmd[@]}"
fi

echo "==> Output: $OUT/"
if ls -1 "$OUT"/*.png >/dev/null 2>&1; then
  ls -1 "$OUT"/*.png
  echo "Report: $OUT/thumbnail_report.json (check launchVisualMetrics + qualityWarnings)"
else
  echo "No PNGs produced — inspect $OUT/thumbnail_report.json for skip/fail reasons."
fi
