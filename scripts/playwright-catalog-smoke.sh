#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

BASE_HREF="${BASE_HREF:-/}"
if [[ "${BASE_HREF}" != "/" && ! "${BASE_HREF}" =~ ^/.*/$ ]]; then
  echo "BASE_HREF must be '/' or start and end with '/'; got: ${BASE_HREF}" >&2
  exit 2
fi

if [[ "${PLAYWRIGHT_SKIP_BUILD:-0}" != "1" ]]; then
  FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"
  if [[ ! -x "${FLUTTER_BIN}" ]]; then
    FLUTTER_BIN="$(command -v flutter || true)"
  fi
  if [[ -z "${FLUTTER_BIN}" ]]; then
    echo "flutter not found; set FLUTTER_BIN" >&2
    exit 1
  fi

  "${FLUTTER_BIN}" build web \
    --release \
    --no-wasm-dry-run \
    --base-href "${BASE_HREF}" \
    --dart-define=PLAYWRIGHT_CATALOG_SMOKE=true \
    --dart-define=PLAYWRIGHT_CATALOG_SMOKE_MAX_GPU_ITERATIONS="${PLAYWRIGHT_CATALOG_SMOKE_MAX_GPU_ITERATIONS:-10}"
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

PLAYWRIGHT_PROJECT="${PLAYWRIGHT_PROJECT:-firefox}"
args=(test tests/playwright/catalog-smoke.spec.mjs --workers=1)
if [[ "${PLAYWRIGHT_PROJECT}" != "all" ]]; then
  args+=(--project "${PLAYWRIGHT_PROJECT}")
fi

npx playwright "${args[@]}"
