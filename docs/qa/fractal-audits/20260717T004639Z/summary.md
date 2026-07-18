# Full fractal audit summary

record: `docs/qa/fractal-audits/20260717T004639Z/`

device: Linux GPU under Xvfb (AMD Radeon RX 6800 XT)

assets: write-protected; `UPDATE_CATALOG_THUMBS` was unset

## Reproducibility and consistency review

- base revision: `36f18e3a351dfa524c00994ce734556205d02b15`
- reproduction environment: Flutter 3.44.2, Dart 3.12.2, Linux 6.17.0-35-generic x86_64, AMD Navi 21 (`1002:73bf`)
- deterministic inputs: all runs used seed `catalog-thumbnails-v1`, 96×96 staged-smoke output, and forced GPU rendering; full audits used batch size 8
- baseline state: base revision before the Rule 150 shader edit; final state: the same revision plus the fix paths listed below
- all three JSON reports parse successfully; within each report, `selectedEntries`, `generated`, `renderMetrics`, `performance`, and `mathOracle` contain the same unique module-ID set with no missing or extra entries
- every generated row has matching catalog ID, shader asset, nested/top-level metric, oracle, and performance records; PNG byte counts and paths agree across those records
- every image is 96×96 with one unique `build/test_output/catalog_thumbs_seeded/<moduleId>.png` filename; no duplicate or mismatched filenames exist
- render verdicts reconcile to 977 pass / 0 non-pass for both full reports and 1 pass for the focused report; warning arrays and top-level warning lists are empty; math verdicts exactly match each report summary
- baseline and final selected-entry sets are identical; their math-oracle records are identical; all summary counts and the five slowest final renders match the archived reports
- PNGs were written to ignored `build/test_output/...` and are not bundle members by design; the archived JSON reports and the recorded Rule 30 hash are the durable evidence

Raw report SHA-256 checksums:

```text
402658426f0ef798ce0d85aa71aa063370ba7b5c88130a3de100281d67be25ba  baseline_thumbnail_report.json
5a7202282723b4b2ae25650bab059e3b8cd7e075e0112b6d4db646e9a42eadd3  postfix-1_rule150_thumbnail_report.json
cbcc00991c24f2a2c7161d91c59e38ca87e450c7e5c7db7b0697d51d772dd782  final_thumbnail_report.json
```

### Launch Thumbnail Standard check

`CONTEXT.md` defines 320×320 only for bundled launch-critical catalog assets and permits smaller staged-smoke generation artifacts. These audit reports all declare `thumbnailStandard: staged-smoke`, `thumbnailSize: 96`, and `updateAssets: false`; they consistently validate 96×96 render health but are not evidence that the separate 320×320 Launch Thumbnail Standard was produced.

All 977 currently referenced build PNGs exist, have valid PNG headers, and decode to the reported 96×96 dimensions. Current files match every byte count in the final and focused reports. Sixteen baseline rows no longer match the current file byte counts because later runs reused and overwrote the same ignored build paths: `newton_z3`, `halley`, `schroeder`, `chebyshev_halley_param`, `fractal_dream`, `gray_scott_rd`, `jason_rampe_1`, `julia`, `king`, `magnetic_pendulum`, `mandelbrot_hardgrad`, `orbit_trap_point`, `symmetric_icon`, `traub_ostrowski`, `weierstrass_elliptic`, and `f0534_weierstrass_elliptic`. Their archived baseline JSON remains unchanged, but the referenced PNGs are not immutable baseline artifacts.

A 320×320 validation run was not performed: it would require `UPDATE_CATALOG_THUMBS=true`, which writes bundled catalog assets and needs explicit approval under the audit and current runtime-thumbnail policy.

Known raw-report limitations retained rather than rewriting evidence:

- the reports have no `generatedAt` field; the UTC record-directory name is the timestamp
- merged `batchReports` entries are execution-time `/tmp` paths, not bundle members, and must not be used as durable evidence; the merged arrays are authoritative
- `final_thumbnail_report.json` has top-level `strict: false` because child batches run non-strict; the wrapper applied `STRICT_CATALOG_THUMBS=true` to the merged report and passed with zero failures, skips, or warnings
- the embedded performance note says three 500ms pumps, but the wrapper defaults `CATALOG_AUDIT_FAST=true`; these runs used the integration test's 120ms and 80ms pumps. Recorded stopwatch timings remain comparable because baseline and final used the same mode

## Commands

- `bash -n scripts/run_fractal_render_audit.sh`: pass
- baseline: `env -u CATALOG_THUMB_LIMIT -u CATALOG_THUMB_OFFSET -u CATALOG_THUMB_ONLY -u UPDATE_CATALOG_THUMBS -u STRICT_CATALOG_THUMBS xvfb-run -a scripts/run_fractal_render_audit.sh`: pass
- focused Rule 150: `env CATALOG_THUMB_ONLY=rule150_linear_ca STRICT_CATALOG_THUMBS=true xvfb-run -a scripts/run_fractal_render_audit.sh`: pass
- final: `env -u CATALOG_THUMB_LIMIT -u CATALOG_THUMB_OFFSET -u CATALOG_THUMB_ONLY -u UPDATE_CATALOG_THUMBS STRICT_CATALOG_THUMBS=true xvfb-run -a scripts/run_fractal_render_audit.sh`: pass
- `flutter analyze`: pass
- `flutter test`: pass (1803 passed, 5 skipped)
- `git diff --check`: pass

## Baseline

- selected: 977
- generated: 977
- failed: 0
- skipped: 0
- warnings/non-pass: 0
- Flutter errors: 0
- math oracle: pass 7, fail 0, skipped 970
- report: `baseline_thumbnail_report.json`

### Baseline performance outlier

`rule150_linear_ca` took 8413.1ms total, including 6292.7ms capture. Its shader enumerated 6,561 signed subsets and 8 bits for every pixel. The output passed image health, but the cost was an objective shared-renderer performance defect.

## Fix slice

### Rule 150 exact carry-parity optimization

- paths: `shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag`, `test/modules/rule150_shader_contract_test.dart`
- affected modules: `rule150_linear_ca` directly; shared shader compilation also covers `rule90_linear_ca` and `wolfram_rule30`
- change: replaced 6,561×8 signed-subset enumeration with an equivalent 11-step signed-binary carry-parity dynamic program; this also covers user-selected generations above 255 up to the shader's 500-iteration cap
- math proof: exhaustive local comparison matched all 256 baseline generations across cells -256 through 256
- focused result: 969.2ms total, 243.0ms capture, pass, 0 warnings
- final result: 366.3ms total, 60.8ms capture, pass, 0 warnings
- image-health metrics remained identical to baseline: 5105 PNG bytes, 488 unique RGB colors, luminance mean 51.4611, luminance stddev 39.1087, dominant-color ratio 0.921
- focused report: `postfix-1_rule150_thumbnail_report.json`

### Shared-shader Rule 30 regression check

The `HEAD` shader and optimized working-tree shader were each rendered with `CATALOG_THUMB_ONLY=wolfram_rule30` under the same strict GPU audit. Their 96×96 PNG files were byte-identical (`sha256 e3e980b25dbd4de473689d3b2fbf777b87d8091eb75dc3318bfb17c141705920`), with 14,154 bytes, 1,698 unique RGB colors, luminance mean 105.89, and luminance standard deviation 79.8017. The focused audit passed with no failures, skips, warnings, or Flutter errors.

## Final strict audit

- selected: 977
- generated: 977
- failed: 0
- skipped: 0
- warnings/non-pass: 0
- Flutter errors: 0
- render health: pass 977, all-black 0, mostly-black 0, transparent 0, blank 0
- math oracle: pass 7, fail 0, skipped 970
- report: `final_thumbnail_report.json`

## Slowest final renders

- 2945.4ms `f1125_fractal_flame_v24_pdj`
- 2917.5ms `f1138_fractal_flame_v37_pie`
- 2804.1ms `f1136_fractal_flame_v35_gaussian_blur`
- 2754.0ms `lichtenberg_growth`
- 2546.9ms `f1120_fractal_flame_v19_power`

These remaining renders pass all image-health and strict gates. No further edits were made without a correctness failure or a defined performance budget; reducing their bounded orbit work would trade visual detail without an evidence-backed acceptance threshold.
