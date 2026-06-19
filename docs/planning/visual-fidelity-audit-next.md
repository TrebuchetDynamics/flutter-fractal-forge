# Visual Fidelity Audit — Next Improvement Slice

## Accepted focus

Prioritize the launch-critical **Visual Fidelity Audit** for the **Featured Launch Set** and catalog thumbnails before adding more fractal families or broad shader polish.

## Evidence checked

- `CONTEXT.md`: defines Featured Launch Set, Trust-Breaking First-Impression Defect, Visual Fidelity Audit, Seeded Thumbnail Palette.
- `TODO.md`: P0 still lists app icon overhaul, improved catalog thumbnails, visual playtest audit, high-zoom panning, continuous auto-zoom.
- `docs/planning/PRD.md`: says catalog thumbnails are shipped at 320×320 and 199 PNGs, but current repo has many more thumbnails.
- `integration_test/catalog/generate_gpu_thumbnails_test.dart`: GPU thumbnail generator stages 256×256 smoke output by default and writes 320×320 bundled assets only with `UPDATE_CATALOG_THUMBS=true`.
- `test/features/catalog/catalog_thumbnail_plan_test.dart`: protects exact asset mapping and approximate-preview labels.
- `assets/catalog_thumbs/`: current checkout has 1347 PNG thumbnails.
- Dirty worktree: icon assets, thumbnail generator, renderer/provider/viewer files, and golden failure artifacts are already modified; treat as in-scope launch-work evidence, not permission to overwrite.

## Findings

### 1. Featured Launch Set is a glossary term, not an executable manifest

The docs say first-time screenshots, GIFs, website copy, and soft-launch guidance should use the Featured Launch Set, but code/tests do not expose a small canonical list. This makes visual QA drift likely: audits can accidentally test whatever is visible in the catalog rather than the launch path.

**Improve:** add a tiny manifest/test fixture for launch IDs, e.g. Mandelbrot, Julia, Burning Ship, Newton/Nova, Mandelbulb/Mandelbox, Barnsley/Koch or another non-escape-time exemplar if supported.

### 2. Thumbnail quality docs conflicted with generator settings

`docs/planning/PRD.md` records 320×320 thumbnails, while the GPU generator previously wrote 256×256 for every output. `TODO.md` still says “Improve catalog thumbnails,” and the repo now has 1347 PNGs, not the older 199-record state.

**Improve:** keep the accepted Launch Thumbnail Standard: 320×320 for bundled catalog assets; 256×256 only for staged smoke output.

### 3. Current thumbnail quality gates catch blank images, not launch aesthetics

The generator checks PNG size, unique RGB colors, luminance standard deviation, and non-transparent pixel ratio. Useful, but it does not catch bad framing, low-detail center, edge crowding, palette sameness, text contrast, or “all thumbnails look alike.”

**Improve:** add audit metrics per Featured Launch Set thumbnail:

- center-detail score
- edge-detail score
- luminance stddev
- palette diversity / dominant-color ratio
- non-transparent ratio
- perceptual hash delta from previous blessed image
- human-readable verdict: `pass`, `needs-framing`, `needs-palette`, `shader-error`, `fallback-preview`

### 4. Golden failure artifacts are currently present

`test/golden/failures/catalog_*` files are modified in the worktree. They may be useful evidence, but the audit should not approve a launch path until these are either resolved, archived as known failures, or regenerated with a deliberate baseline decision.

**Improve:** make Visual Fidelity Audit closeout require “no unexplained golden failure artifacts.”

### 5. Visual playtest should be family-stratified, not catalog-wide first

Research and TODO both show many fractal families need different render paths: escape-time, 3D raymarch, IFS/geometric, attractors, cellular automata, tilings. A catalog-wide pass is too noisy for a first launch gate.

**Improve:** first audit one representative per family in the Featured Launch Set, then expand to long-tail catalog.

## Recommended implementation slices

### Slice A — Launch visual manifest (smallest safe next code change)

Status: implemented in `lib/features/catalog/featured_launch_set.dart` with coverage in `test/features/catalog/featured_launch_set_test.dart`.

The test asserts:

- each ID exists in `ModuleRegistry`
- each has an exact thumbnail asset via `CatalogThumbnailPlan`
- none resolves to a diagnostic shader
- each can be selected in `FractalController`

Validation target: a fast unit/widget test, no GPU required.

### Slice B — Thumbnail standard alignment

Status: implemented as **Launch Thumbnail Standard** in `CONTEXT.md` and aligned in `integration_test/catalog/generate_gpu_thumbnails_test.dart`.

Accepted standard:

- bundled catalog assets: 320×320 PNGs
- staged smoke output: 256×256 PNGs

Validation target: `flutter test test/features/catalog/catalog_thumbnail_plan_test.dart` plus a 3–5 item staged generation smoke when GPU test runner is available.

### Slice C — Audit report schema

Status: implemented as **Launch Visual Metrics** in `CONTEXT.md` and `lib/features/catalog/launch_visual_metrics.dart`; generated reports now include `launchVisualMetrics` for Featured Launch Set entries only.

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

- classify current golden failure images
- verify app icon adaptive assets
- rerun catalog/web smoke path
- record final Visual Fidelity Audit verdict

## Stop conditions

Do not do a broad shader rewrite. Do not add new fractal families until Slice A and Slice B pass. Do not bless visual output without deterministic seed, artifact paths, and metrics.
