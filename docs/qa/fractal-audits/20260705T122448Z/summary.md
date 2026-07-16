# Full fractal audit summary

## Status

Blocked by Flutter/Linux shader tooling before a clean full GPU audit can complete.

## Evidence

- Full single-process audit selected 1585 modules, generated 28, failed 1557 with repeated `Asset '<shader>.frag' not found` even though sampled shader files exist in `shaders/`, are declared in `pubspec.yaml`, and are present under `build/linux/x64/debug/bundle/data/flutter_assets/`.
- Focused checks such as `CATALOG_THUMB_ONLY=buffalo scripts/run_fractal_render_audit.sh` and `CATALOG_THUMB_ONLY=mandelbrot,buffalo scripts/run_fractal_render_audit.sh` pass, proving the reported missing assets are false negatives from repeated shader loads in one process.
- Isolated batch attempts avoid some false missing-asset failures but Flutter build then fails before test execution with CMake/impellerc shader output errors such as missing `build/flutter_assets/.../*.frag.spirv`.

## Counts from full single-process baseline

selected=1585 generated=28 failed=1557 skipped=0 warnings=28

## Next safe fix target

Make the audit pipeline independent of Flutter's all-shader Linux build/install path, or add a dedicated app/test target whose shader manifest contains only the batch under test. Then rerun the full audit and fix per-fractal render/math failures from the merged report.
