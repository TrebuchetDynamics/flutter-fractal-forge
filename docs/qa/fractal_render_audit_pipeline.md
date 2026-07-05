# Fractal render audit pipeline

Use the GPU thumbnail integration test as the catalog-wide render-health pipeline. It renders every non-diagnostic catalog entry by default, records load/render/capture timings, captures a PNG, writes objective image metrics, and runs cheap CPU/reference math oracles where stable known points exist.

## Run

```bash
# Fast smoke: first 5 fractals
CATALOG_THUMB_LIMIT=5 scripts/run_fractal_render_audit.sh

# Full catalog audit: every non-diagnostic catalog fractal.
# The wrapper forces real GPU rendering and merges isolated batches.
scripts/run_fractal_render_audit.sh

# Tune batch size or re-enable direct FragmentProgram preflight timing when diagnosing shader loading itself
CATALOG_AUDIT_BATCH_SIZE=10 scripts/run_fractal_render_audit.sh
CATALOG_SKIP_SHADER_PREFLIGHT=false scripts/run_fractal_render_audit.sh

# Fail the run on crashes or image-health warnings
STRICT_CATALOG_THUMBS=true scripts/run_fractal_render_audit.sh

# Equivalent raw Flutter command
flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart \
  -d linux \
  --dart-define=FORCE_GPU_RENDER=true
```

## Output

Desktop output is written to:

```text
build/test_output/catalog_thumbs_seeded/thumbnail_report.json
```

Important report fields:

- `selectedCount` — number of fractals selected for the run.
- `isolatedBatches` / `batchSize` / `batchReports[]` — present when the wrapper merged multiple Flutter test processes.
- `performance[].shaderLoadMode` — `renderer-warmup` by default; `preflight` when `CATALOG_SKIP_SHADER_PREFLIGHT=false`.
- `generated[]` / `failed[]` / `skipped[]` — per-fractal status.
- `performance[]` — `shaderLoadMs`, `moduleSelectMs`, `renderWarmupMs`, `captureMs`, `totalMs`, frame timing stats.
- `renderMetrics[]` — `blackPixelRatio`, `nonBlackPixelRatio`, `transparentPixelRatio`, `uniqueRgbColors`, `luminanceStdDev`, `dominantColorRatio`, `verdict`, `warnings`.
- `renderHealthSummary` — pass/all-black/mostly-black/transparent/flat/low-color/blank counts plus thresholds.
- `mathOracle[]` — per-fractal CPU/reference known-point checks and `verdict` (`pass`, `fail`, or `skipped`).
- `mathOracleSummary` — pass/fail/skipped counts for the selected run.
- `generated[].mathVerdict` — shortcut field for triage tables.

Use `blackPixelRatio`, render `verdict`, and `mathVerdict` to prioritize broken or mathematically suspect fractals before deeper shader debugging. Unsupported formulas intentionally report `skipped`; add a known-point oracle only when the expected math is stable.
