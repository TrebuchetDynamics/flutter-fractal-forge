# Visual Fidelity Audit — Next Improvement Slice

## Accepted focus

Prioritize the launch-critical **Visual Fidelity Audit** for the **Featured Launch Set** and catalog thumbnails. The owner-approved visual-improvement task extends the work beyond that first tranche. It includes both Explore groups and all 200 research-library definitions. The Featured Launch Set remains the first audit phase; this extension does not make a blanket shader rewrite part of scope.

Review true module defaults, runtime catalog previews, and first viewer renders. Preserve established formulas. Tune defaults and rendering, or fix demonstrated implementation bugs.

## Evidence checked

- `CONTEXT.md`: defines Featured Launch Set, Trust-Breaking First-Impression Defect, Visual Fidelity Audit, Seeded Thumbnail Palette.
- `TODO.md`: app icon visual sign-off and the full visual playtest audit remain open; catalog thumbnail improvements and continuous auto-zoom are marked complete.
- `docs/planning/PRD.md`: current policy keeps catalog thumbnails runtime-rendered, with no static catalog PNGs in the bundle. The 320×320 Launch Thumbnail Standard applies to launch-set thumbnail media outputs; 256×256 remains valid for staged smoke output.
- `integration_test/catalog/generate_gpu_thumbnails_test.dart`: stages 256×256 smoke output by default, can capture launch media at `LAUNCH_MEDIA_SIZE`, and has a separate opt-in catalog-asset write path (`UPDATE_CATALOG_THUMBS=true`) that is not the current shipping policy.
- `test/features/catalog/catalog_thumbnail_plan_test.dart`: protects exact asset mapping and approximate-preview labels.
- `assets/catalog_thumbs/`: the static thumbnail directory is absent in this checkout; `test/catalog/catalog_thumbnail_audit_test.dart` protects that state.
- `test/golden/failures/catalog_*` contains tracked failure-output images. `test/golden/catalog_golden_test.dart` passed all four phone/tablet dark/high-contrast cases in the inspected run; those stored artifacts were not reproduced by that run.

## Current implementation evidence — partial

The working tree has formula-preserving fixes across four module paths. Julia and Nova now resolve to their dedicated modules. Newton z³ supplies the relaxation uniform at `1.0`. Nova convergence checks the full parameter-plane update. Koch Snowflake uses center `(0, 0.3)` and zoom `1.2`. Catalog launches now use a module's configured default view.

VIS-006-BATCH-04 executed real-GPU defaults and actual runtime catalog previews for the next ten source-ordered Explore IDs. All ten runtime previews passed the image-health verdict. The strict default harness reconciled selected/generated/failed/skipped as 10/9/1/0 because Koch Snowflake exceeded the existing black-ratio limit (0.3013 vs <0.2); a non-strict run captured all ten and every rendered image's health verdict was pass. No shader, formula, or default was changed. All ten CPU oracle checks were skipped because no reference oracle is available; tetration is the only selected module with a registered native CPU formula.

VIS-006-BATCH-07 executed strict real-GPU module-default captures and actual runtime catalog previews for `core.vicsek_fractal`, `core.penrose_tiling`, `core.fibonacci_word`, `core.rauzy_fractal`, `core.arnoux_rauzy_fractal`, `core.dual_substitution_tiling`, `core.bedford_mcmullen_carpet`, `core.self_affine_finite_type`, `core.pinwheel_tiling`, and `core.z_order_curve`. Counts reconciled 10/10/0/0 (selected/generated/failed/skipped); all ten default and runtime image-health verdicts pass. Default artifacts are 256×256 and runtime catalog previews 384×346. The ten mathematical reference oracles are skipped (not registered), distinct from the successful GPU rendering. No shader, formula, or default changed; see per-entry paths, effective module parameters, and image metrics in `docs/planning/visual-audit-inventory.json`.

VIS-006-BATCH-09 executed strict real-GPU defaults and actual runtime catalog previews for `core.fractal_canopy`, `core.benesi`, `core.schottky_limit_set`, `core.henon`, `core.tinkerbell`, `core.gingerbreadman`, `core.lozi`, `core.duffing`, `core.ikeda`, and `core.clifford`. Default counts reconciled selected/generated/failed/skipped as 10/10/0/0; all ten defaults (256×256) and runtime previews (384×346) passed image-health checks. Mathematical reference oracles are skipped for all ten. Per-ID paths and metrics are in `docs/planning/visual-audit-inventory.json`; no shader, formula, or module default changed.

VIS-006-BATCH-10 executed strict real-GPU module-default captures and actual runtime catalog previews for `core.peter_de_jong`, `core.svensson`, `core.gumowski_mira`, `core.arnold_cat`, `core.standard_map`, `core.zaslavsky`, `core.kicked_rotator`, `core.chua_circuit`, `core.sprott_a`, and `core.burke_shaw`. Default counts reconciled selected/generated/failed/skipped as 10/10/0/0; all ten defaults (256×256) and runtime previews (384×346) passed image-health checks. Mathematical reference oracles were skipped for all ten. Per-ID paths and metrics are in `docs/planning/visual-audit-inventory.json`; no shader, formula, or module default changed.

VIS-006-BATCH-12 executed strict real-GPU module-default captures and actual runtime catalog previews for `core.moore_spiegel`, `core.hadley`, `core.genesio_tesi`, `core.liu_chen`, `core.newton_leipnik`, `core.bouali`, `core.dequan_li`, `core.coullet`, `core.sakarya`, and `core.qi_chen`. Default counts reconciled selected/generated/failed/skipped as 10/10/0/0; all ten defaults (256×256) and runtime previews (384×346) passed image-health checks. Mathematical reference oracles were skipped for all ten (no registered reference oracle). Per-ID paths and metrics are in `docs/planning/visual-audit-inventory.json`; no shader, formula, or module default changed.

VIS-006-BATCH-13 executed strict real-GPU module-default captures and actual runtime catalog previews for the explicitly scoped IDs `core.yu_wang`, `core.zhou_chen`, `core.tsucs`, `core.rayleigh_benard`, `core.robinson`, `core.globo_toroid`, `core.tamari`, `core.wang_sun_cang`, `core.newton_z3`, and `core.halley`. These are not the next ten in the inventory's current alphabetical Explore-row order; the actual next ten uncaptured IDs are `core.householder`, `core.zeta_newton`, `core.magnet_newton`, `core.hypercomplex_newton`, `core.quaternion_julia_2d`, `core.tessarine_julia`, `core.split_complex`, `core.dual_complex`, `core.bicomplex`, and `core.sine_julia`. Default counts reconciled selected/generated/failed/skipped as 10/10/0/0; all ten defaults (256×256) and runtime previews (384×346) passed image-health checks. Mathematical reference oracles were skipped for all ten. CPU correctness and first-view behavior remain NOT_CHECKED; the inventory's existing `cpu_formula: not audited` values are not CPU verification, and no first-view evidence was added except the already-recorded Newton z³ check. Per-ID paths and metrics are in `docs/planning/visual-audit-inventory.json`; no shader, formula, or module default changed.

Real-GPU checks use `--dart-define=FORCE_GPU_RENDER=true`. Default and runtime-preview checks now have evidence for Julia, Nova, Newton z³, Koch Snowflake, Burning Ship, Four-Wing, Lorenz 2D, Mandelbrot, Rössler 2D, and Thomas Attractor. Viewer-start checks cover all nine Featured Launch Set IDs: seven in `user_flows_test.dart`, plus dedicated Nova and Newton z³ tests. Koch's 256×256 default capture reports 1,591 unique RGB colors and 17.09% black pixels. Its runtime preview is 384×346. These are focused samples, not full-catalog coverage.

The visual inventory reconciles 1,027 Explore IDs (core=1,027; performance=0) and 200 research-manifest IDs. It records default capture/runtime-preview evidence for 127 Explore rows; 900 remain uncaptured. All 200 research rows are explicitly marked `missing_app_renderer`, so no app preview or first viewer render is available for them. The `first_view` field is populated for nine Explore rows. Its `cpu_formula` field is `not audited` in 1,164 of the 1,227 rows. The visual-inventory validator checks references and shader paths, not render quality. The remaining coverage is tracked in [`TODO.md`](../../TODO.md).

An earlier 1,020-entry GPU capture timed out. Its report did not reconcile with the 907 PNG files found. It is not complete-coverage evidence. Four-Wing, Lorenz, Rössler, and Thomas captures also have documented visual findings that need follow-up. Keep their established formulas unchanged unless an implementation defect is demonstrated.

## Findings

### 1. Featured Launch Set manifest — resolved

The canonical list now exists as `kFeaturedLaunchSetModuleIds` in `lib/features/catalog/data/featured_launch_set.dart`. `test/features/catalog/featured_launch_set_test.dart` checks registry presence, exact thumbnail mapping, non-diagnostic modules, and controller selection.

The manifest is intentionally scoped for visual QA; the broader marketing set still has separate coverage requirements below.

### 2. Thumbnail standard — scope resolved

The owner confirmed that 320×320 applies to launch-set thumbnail media outputs, not bundled catalog thumbnails. `assets/AGENTS.md` and `test/catalog/catalog_thumbnail_audit_test.dart` continue to require the static catalog PNG bundle to remain absent; catalog thumbnails are rendered at runtime. The generator's `LAUNCH_MEDIA_SIZE=320` mode produces launch-set thumbnail-sized output under `build/test_output/launch_media/`; its default high-resolution capture remains 1080×1080. Staged smoke output may use 256×256. The separate `UPDATE_CATALOG_THUMBS=true` path can write catalog assets, but is not the current shipping policy.

Do not treat the opt-in catalog-asset write path as permission to add static catalog thumbnails. The dedicated 320×320 Featured Launch Set capture is verified; see the MEDIA-001 evidence in `TODO.md`.

### 3. Launch visual metrics — implemented, descriptive only

`lib/features/catalog/data/launch_visual_metrics.dart` implements center-detail, edge-detail, luminance, dominant-color, non-transparent, and verdict metrics for Featured Launch Set entries. The audit report schema emits these metrics, but they are descriptive rather than an acceptance threshold.

They do not automatically judge subjective framing or visual variety. Do not claim those are enforced quality gates; any enforcement change needs explicit measurable criteria.

### 4. Stored golden failure artifacts are not currently reproduced

The tracked `test/golden/failures/catalog_*` images remain in the repository, but `test/golden/catalog_golden_test.dart` passed all four configured comparisons in the inspected run. Treat these as stored failure-output artifacts, not evidence of a currently failing golden test. Their retention or removal is a repository-maintenance decision; do not regenerate baselines merely to clear the files.

Visual-audit closeout should distinguish retained failure-output artifacts from failures reproduced by the golden test; the inspected run passes, while the stored images remain tracked.

### 5. Visual playtest should be family-stratified, not catalog-wide first

Research and TODO both show many fractal families need different render paths: escape-time, 3D raymarch, IFS/geometric, attractors, cellular automata, tilings. A catalog-wide pass is too noisy for a first launch gate.

**Improve:** first audit one representative per family in the Featured Launch Set, then expand to long-tail catalog.

## Recommended implementation slices

### Slice A — Launch visual manifest (implemented)

Status: implemented in `lib/features/catalog/data/featured_launch_set.dart` with coverage in `test/features/catalog/featured_launch_set_test.dart`.

The test asserts:

- each ID exists in `ModuleRegistry`
- each has an exact thumbnail asset via `CatalogThumbnailPlan`
- none resolves to a diagnostic shader
- each can be selected in `FractalController`

Validation target: a fast unit/widget test, no GPU required.

### Slice B — Thumbnail standard alignment

Status: scope is documented and the 320×320 launch-media capture is verified by the MEDIA-001 evidence in `TODO.md`.

Launch Thumbnail Standard:

- launch-set thumbnail media output: 320×320 PNG, generated under `build/test_output/launch_media/` with `LAUNCH_MEDIA_SIZE=320`
- staged generation smoke output: 256×256 PNG
- static catalog PNGs: not bundled; catalog thumbnails remain runtime-rendered
- separate high-resolution hero stills: 1080×1080 by default, configurable per capture run

Validation target met: `LAUNCH_MEDIA_SIZE=320 ./scripts/capture-launch-media.sh` ran on a real GPU; the MEDIA-001 report lists all nine Featured Launch Set entries at 320×320 with no failed renders or quality warnings. The catalog asset-update path remains out of scope.

### Slice C — Audit report schema

Status: implemented as **Launch Visual Metrics** in `CONTEXT.md` and `lib/features/catalog/data/launch_visual_metrics.dart`; generated reports now include `launchVisualMetrics` for Featured Launch Set entries only.

Metrics included:

- center-detail score
- edge-detail score
- luminance stddev
- dominant-color ratio
- non-transparent ratio
- human-readable verdict: `pass`, `needs-framing`, `needs-palette`, `fallback-preview`

Validation target: strict mode fails only on existing measurable generation defects; Launch Visual Metrics are descriptive until a later enforcement decision.

### Slice D — Resolve visible launch artifacts

Before launch screenshots:

- [x] classify stored catalog golden-failure images against the four passing current golden comparisons; leave the tracked artifacts unchanged
- [x] verify launcher/store source files (1024×1024 launcher and adaptive foreground, 512×512 store icon, 1024×500 feature graphic), `pubspec.yaml` launcher inputs, and Android adaptive-icon XML/resources; visual presentation sign-off remains open
- [x] rerun catalog/web smoke path and inspect the report (Featured Launch Set Chromium smoke: 9/9 modules, zero failures or warnings; see `TODO.md` WEB-001 evidence)
- [ ] record final Visual Fidelity Audit verdict

## Extended audit scope — in progress

The accepted visual-improvement task also covers both Explore groups and the 200 reference definitions in `research/fractals-library/data/fractal_manifest.json`. This is separate from the Featured Launch Set media policy above. The ID inventory is reconciled, but rendering, CPU-formula, and first-view evidence is partial. The 200 reference definitions have no app renderer in the current inventory.

The next bounded steps are tracked in [`TODO.md`](../../TODO.md):

- `VIS-004`: the nine Featured Launch Set first-view checks have executed evidence, including dedicated Nova and Newton z³ tests.
- `VIS-005`: ID and renderer-status reconciliation is complete. It does not prove visual output or CPU-formula coverage.

`VIS-006` in `TODO.md` tracks the remaining GPU captures, runtime previews, first viewer renders, and supported CPU checks. The next batch should name ten uncaptured Explore IDs. Do not count a batch as complete until its selected, generated, failed, and skipped counts reconcile. Keep formula redesign and static catalog assets out of scope.

## Stop conditions

Do not do a broad shader rewrite. Do not add new fractal families until Slice A and Slice B pass. Do not bless visual output without deterministic seed, artifact paths, and metrics.
