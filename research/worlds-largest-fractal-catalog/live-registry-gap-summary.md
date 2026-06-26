# Live Registry Gap Summary

## Purpose

Measure the current production `ModuleRegistry` against the 5,000–10,000 curated renderable entry objective without counting random presets.

## Probe command

A temporary Flutter test probe and the committed guardrail test inspect:

- `ModuleRegistry`
- `CatalogRepository.fromRegistry`
- shader asset paths on each `FractalModule`
- `CatalogThumbnailPlan` asset paths

Committed guardrail:

```sh
flutter test test/features/catalog/world_largest_catalog_goal_test.dart
```

## Current live registry numbers

Observed by probe:

| Metric | Count |
|---|---:|
| Total registry modules | 5239 |
| Diagnostic modules | 7 |
| Non-diagnostic modules | 5232 |
| Non-diagnostic modules with existing shader asset | 5232 |
| Non-diagnostic modules with existing thumbnail asset | 5202 |
| Counted promoted live-registry entries | 5202 |
| Thumbnail-backed but unknown-family modules | 0 |
| Missing shader assets | 0 |
| Missing thumbnail assets | 30 |

## Interpretation

The current app has **472 shader-backed non-diagnostic live modules**, which are real renderable candidates. However, they do **not** complete the 5k–10k objective because:

1. 472 is below 5,000.
2. 30 live modules still lack bundled catalog thumbnails.
3. The world-largest count requires formula/rule provenance per promoted entry, not just module presence.
4. Random presets, palette variants, and camera views must remain excluded.

## Promotion implication

The fastest honest path is:

1. Use live registry modules as a high-confidence promotion source.
2. Add thumbnail generation for the 273 missing live modules.
3. Add/derive formula-or-rule provenance for each live module.
4. Promote live modules into the counted ledger only after validator gates pass.
5. Continue with generated metadata leads after shader linkage is resolved.

Machine-readable thumbnail blocker worklist:

- `thumbnail-worklist.live-registry.json`
- missing thumbnail modules: 30
- batch size: 25
- batch count: 2

Each batch includes a ready `CATALOG_THUMB_ONLY=... flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux` command.

Batch runner:

```sh
# Dry-run batch 0; does not write assets.
python3 research/worlds-largest-fractal-catalog/run_thumbnail_batch.py --batch 0

# Execute batch 0 into staged output only.
python3 research/worlds-largest-fractal-catalog/run_thumbnail_batch.py --batch 0 --execute

# Execute batch 0 and write bundled catalog assets. Use only when asset churn is intended.
python3 research/worlds-largest-fractal-catalog/run_thumbnail_batch.py --batch 0 --execute --update-assets
```

Execution receipts append to `thumbnail-batch-receipts.jsonl`.

Observed staged batch 0 results on Linux:

1. Before fallback capture:
   - command exited 0
   - selected 25 modules
   - generated 0 thumbnails
   - skipped 1 due `MissingPluginException(No implementation found for method captureScreenshot on channel plugins.flutter.io/integration_test)`
   - receipt result: `no-output`
2. After adding `RepaintBoundary.toImage` fallback but before forcing real GPU rendering:
   - command exited 0
   - selected 25 modules
   - generated 25 staged thumbnails under `build/test_output/catalog_thumbs_seeded/`
   - skipped 0, failed 0
   - quality warnings 25/25: flat one-color output (`unique RGB colors 1 < 16`, `luminance stddev 0.00 < 3.0`)
3. After adding `--dart-define=FORCE_GPU_RENDER=true` to the batch runner:
   - command exited 0
   - selected 25 modules
   - generated 25 staged thumbnails
   - skipped 0, failed 0
   - quality warnings 0
   - 25 PNGs were copied into `assets/catalog_thumbs/` without overwriting existing assets
4. Regenerated worklist batch 0 with strict bundled writes:
   - command exited 0 with `--update-assets --strict`
   - selected 25 modules
   - generated 25 bundled thumbnails under `assets/catalog_thumbs/`
   - skipped 0, failed 0, quality warnings 0
5. Next regenerated worklist batch 0 with strict bundled writes:
   - command exited 1 because `STRICT_CATALOG_THUMBS` rejected 5 quality warnings
   - selected 25 modules
   - generated 25 files, but only 20 had no quality warnings
   - warning thumbnails were removed for `sprott_c`, `newton_z4`, `newton_z6`, `tangent_julia`, and `newton_z5`
   - the 20 clean bundled thumbnails remain promoted

6. Two custom strict batches skipped known warning IDs from the regenerated worklist:
   - retained 19 clean thumbnails; removed warning thumbnail `celtic_power5`
   - retained 17 clean thumbnails; removed warning thumbnails `celtic_power5_julia` and `magnet2_julia`
7. Three more custom strict batches skipped known warning IDs:
   - retained 16 clean thumbnails; removed warning thumbnail `multijulia9`
   - retained 15 clean thumbnails; removed warning thumbnail `tricorn_power7_julia`
   - retained 14 clean thumbnails; removed warning thumbnail `lichtenberg_growth`
   - 8 newly thumbnail-backed modules are still excluded from the counted ledger as `unknownFamily`
8. Four more strict subsets retained 34 clean thumbnails while removing warning outputs for `bedhead`, `bogdanov_map`, `buddhabrot_full`, `fractal_dream`, `jason_rampe_1`, `jason_rampe_2`, `kleinian_limit_set`, `laguerre_fractal`, and `magnetic_pendulum`.
9. Final live thumbnail pass retained 58 additional clean thumbnails. Warning outputs were removed for `mandelbrot_df2`, `mandelbrot_simple`, `mandelbrot_tex`, `noor_newton`, `shape_modulus_julia`, `symmetric_icon`, `weierstrass_elliptic`, `mandelbox`, `mandelbox_shape_inversion`, and `amazing_box`.
10. Target-family mapping was expanded for existing live categories that were previously `unknownFamily`: `Convergent & Root-Finding`, `IFS / Geometric Fractals`, `Kaleidoscopes`, and `Cellular & Stochastic Growth`. These are counted as stable formula/rule or transform-system identities, not presets.

So 243 new clean thumbnails were promoted to bundled assets, and all 5202 thumbnail-backed live modules currently count under the target-family rules after adding all 50 reviewed shared-Julia formula identities, 3 Phoenix degree identities, 1 exact Sprott C identity, 18 reviewed 3D parameter identities, 7 residual CA rule identities, 99 Elementary CA rule identities, and 18 Multibrot exponent identities, 2 Mandelbrot power identities, and 17 Tricorn/Burning Ship power identities, and 14 unique sine/cosine expression identities, and 24 orbit-trap geometry identities, 1 forest-fire CA rule identity, 3 Quaternion Julia constants, and 2 KIFS/Menger family identities, 1 reviewed Möbius rational-map expression, and 10 direct transcendental formula identities, plus 7 additional exp/log/tan expression formula identities and 28 outer-totalistic B/S cellular-automata rule identities and 3 fixed named CA rules and 41 supported fractal-flame variation rules and 1 parameterized Weierstrass function identity and 2 direct 3D KIFS identities and 22 additional thumbnail-backed Elementary CA rule identities and 14 exact Sprott strange-attractor formula identities and 8 named Life-like B/S cellular-automaton rule identities and 42 exact strange-attractor formula/map identities and 32 Clifford coefficient-map identities and 20 Svensson coefficient-map identities and 13 Martin/Hopalong coefficient-map identities and 22 Peter de Jong coefficient-map identities and 6 Lozi coefficient-map identities and 4 unique Tinkerbell a-coefficient identities and 16 Gumowski-Mira coefficient-map identities and 6 exact escape/root/orbit formula identities and 3 Standard Map K identities and 4,200 systematic Life-like B/S rule identities. Remaining thumbnail gaps are all known strict-quality rejects tracked in the regenerated worklist.

## Promoted live-registry ledger

`curated-entry-ledger.live-registry.json` now promotes 5202 live modules that have shader assets, thumbnail assets, and target-family classification. It counts stable `FractalModule` identities only; built-in presets, random seeds, palettes, and camera views remain excluded.

Validation:

```sh
flutter test test/features/catalog/generate_live_registry_ledger_test.dart
python3 research/worlds-largest-fractal-catalog/validate_catalog_goal.py --entries research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json
```

## Completion impact

Current objective status remains incomplete. Live registry proves a strong base of 5232 renderable candidates, but the counted promoted live-registry ledger is 5202, still far below 5,000. The remaining 30 thumbnail gaps are known strict-quality rejects that need framing/render fixes before they can count.
