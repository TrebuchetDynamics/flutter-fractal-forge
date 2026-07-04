#!/usr/bin/env bash
#
# Capture clean, chrome-free, high-resolution marketing stills of the Featured
# Launch Set using curated deep-link coordinates.
#
# Pipeline: build the web bundle with the Playwright smoke hook enabled (but a
# HIGH GPU-iteration cap so stills get real detail, unlike the smoke sweep),
# then run test/playwright/launch-stills.spec.mjs which opens each fractal via
# the chrome-free capture route and screenshots the bare canvas.
#
# Output: test/results/launch-stills/<id>.png + manifest.json
#
# Run on a machine with a REAL GPU for launch-quality output (the same gate as
# capture-launch-media.sh). Coordinates live in
# test/playwright/launch-stills.coords.json — edit and re-run to refine framing.
#
# Usage:
#   ./scripts/capture-launch-stills.sh                       # all 9, 1080px @2x
#   LAUNCH_STILLS_SIZE=1440 ./scripts/capture-launch-stills.sh
#   LAUNCH_STILLS_FILTER='mandelbrot|julia' ./scripts/capture-launch-stills.sh
#   PLAYWRIGHT_SKIP_BUILD=1 ./scripts/capture-launch-stills.sh   # reuse build/web
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

BASE_HREF="${BASE_HREF:-/}"
if [[ "${BASE_HREF}" != "/" && ! "${BASE_HREF}" =~ ^/.*/$ ]]; then
  echo "BASE_HREF must be '/' or start and end with '/'; got: ${BASE_HREF}" >&2
  exit 2
fi

# High cap so launch stills render at full iteration detail. The smoke sweep
# caps this at 10 for speed; marketing stills want quality.
STILLS_GPU_ITER_CAP="${PLAYWRIGHT_CATALOG_SMOKE_MAX_GPU_ITERATIONS:-2000}"

if [[ "${PLAYWRIGHT_SKIP_BUILD:-0}" != "1" ]]; then
  FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
  if [[ ! -x "${FLUTTER_BIN}" ]]; then
    FLUTTER_BIN="$(command -v flutter || true)"
  fi
  if [[ -z "${FLUTTER_BIN}" ]]; then
    echo "flutter not found; set FLUTTER_BIN" >&2
    exit 1
  fi

  echo "==> Building web (smoke hook on, GPU iter cap=${STILLS_GPU_ITER_CAP})"
  "${FLUTTER_BIN}" build web \
    --release \
    --no-wasm-dry-run \
    --base-href "${BASE_HREF}" \
    --dart-define=PLAYWRIGHT_CATALOG_SMOKE=true \
    --dart-define=PLAYWRIGHT_CATALOG_SMOKE_MAX_GPU_ITERATIONS="${STILLS_GPU_ITER_CAP}"
fi

if [[ ! -d build/web ]]; then
  echo "build/web missing; run without PLAYWRIGHT_SKIP_BUILD or build web first" >&2
  exit 1
fi

if ! grep -Fq "<base href=\"${BASE_HREF}\">" build/web/index.html; then
  echo "build/web/index.html does not have expected base href '${BASE_HREF}'" >&2
  echo "Rebuild without PLAYWRIGHT_SKIP_BUILD or set BASE_HREF to match the build." >&2
  exit 1
fi

# Chromium has the most reliable CanvasKit/WebGL path for crisp marketing output.
PLAYWRIGHT_PROJECT="${PLAYWRIGHT_PROJECT:-chromium}"
args=(test test/playwright/launch-stills.spec.mjs --workers=1)
if [[ "${PLAYWRIGHT_PROJECT}" != "all" ]]; then
  args+=(--project "${PLAYWRIGHT_PROJECT}")
fi

echo "==> Capturing launch stills (project=${PLAYWRIGHT_PROJECT}, size=${LAUNCH_STILLS_SIZE:-1080}, scale=${LAUNCH_STILLS_SCALE:-2})"
npx playwright "${args[@]}"

OUT="test/results/launch-stills"
echo "==> Output: ${OUT}/"
if ls -1 "${OUT}"/*.png >/dev/null 2>&1; then
  ls -1 "${OUT}"/*.png
  echo "Manifest: ${OUT}/manifest.json"
else
  echo "No PNGs produced — inspect ${OUT}/manifest.json for open/first-frame failures."
fi
