# Full fractal audit summary

record: `docs/qa/fractal-audits/20260705T171144Z/`

## Commands

- `bash -n scripts/run_fractal_render_audit.sh`: pass
- baseline: `env -u CATALOG_THUMB_LIMIT -u CATALOG_THUMB_OFFSET -u CATALOG_THUMB_ONLY -u UPDATE_CATALOG_THUMBS CATALOG_AUDIT_BATCH_SIZE=20 xvfb-run -a scripts/run_fractal_render_audit.sh`: pass
- focused params/shader fix checks with `STRICT_CATALOG_THUMBS=true`: pass
- final: `env -u CATALOG_THUMB_LIMIT -u CATALOG_THUMB_OFFSET -u CATALOG_THUMB_ONLY -u UPDATE_CATALOG_THUMBS CATALOG_AUDIT_BATCH_SIZE=50 STRICT_CATALOG_THUMBS=true xvfb-run -a scripts/run_fractal_render_audit.sh`: pass
- `flutter analyze`: pass
- `flutter test test/features/renderer/render_audit_metrics_test.dart`: pass
- `git diff --check`: pass

## Baseline counts

`{'selected': 1585, 'generated': 1585, 'failed': 0, 'skipped': 0, 'warnings': 3, 'flutterErrors': 0, 'nonPass': 3, 'math': {'selectedCount': 1585, 'evaluated': 1585, 'pass': 7, 'fail': 0, 'skipped': 1578}}`

Baseline warnings:
- `alternated_iteration` (`core.alternated_iteration`): blank black render: black pixel ratio 1.0000 >= 0.999, unique RGB colors 1 < 3, luminance stddev 0.00 < 0.5
- `secant_julia` (`core.secant_julia`): blank low-detail render: unique RGB colors 1 < 3 and luminance stddev 0.00 < 0.5
- `sierpinski_julia_rational` (`core.sierpinski_julia_rational`): blank black render: black pixel ratio 1.0000 >= 0.999, unique RGB colors 1 < 3, luminance stddev 0.00 < 0.5

## Fix slices

1. Runner reliability: `scripts/run_fractal_render_audit.sh`, `scripts/research/doctor/catalog_audit_assets_for_ids.py`, `scripts/research/doctor/patch_pubspec_shaders.py`
   - Forces GPU rendering, uses batch-specific shader manifests, stores chunks outside `build/`, retries warning/failure batches individually, and enforces strict mode after merge so false batch warnings can be isolated.
2. Missing shader params: `lib/core/modules/builders/escape_time_catalog/kaleidoscopes.dart`
   - Added default extra params for `alternated_iteration`, `bogdanov_map`, `cosecant_julia`, `cotangent_julia`, `secant_julia`, `sierpinski_julia_rational`, `kleinian_limit_set`, `mittag_leffler`, and `noor_newton`.
3. Kleinian opacity: `shaders/ifs_and_geometric/kleinian_limit_set_gpu.frag`
   - Keeps opaque output when transparent background is off.

## Final counts

`{'selected': 1585, 'generated': 1585, 'failed': 0, 'skipped': 0, 'warnings': 0, 'flutterErrors': 0, 'nonPass': 0, 'math': {'selectedCount': 1585, 'evaluated': 1585, 'pass': 7, 'fail': 0, 'skipped': 1578}}`

Final warnings: none

## Top slow final fractals

- 10307.7ms `rule150_linear_ca` `shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag`
- 3817.4ms `f1138_fractal_flame_v37_pie` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`
- 3483.8ms `f1136_fractal_flame_v35_gaussian_blur` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`
- 3444.4ms `lichtenberg_growth` `shaders/cellular_and_stochastic/lichtenberg_growth_gpu.frag`
- 3401.4ms `f1125_fractal_flame_v24_pdj` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`
- 3028.2ms `f1118_fractal_flame_v17_popcorn` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`
- 2808.8ms `f1120_fractal_flame_v19_power` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`
- 2667.2ms `f1116_fractal_flame_v15_waves` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`
- 2431.1ms `f1112_fractal_flame_v11_diamond` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`
- 1865.4ms `f1102_fractal_flame_v1_sinusoidal` `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag`

## Archived reports

- baseline: `baseline_thumbnail_report.json`
- final: `final_thumbnail_report.json`
- final log: `final-batch50-strict-output-2.log`
- intermediate strict failures and timeout evidence are preserved in this folder.
