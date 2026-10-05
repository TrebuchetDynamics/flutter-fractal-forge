# Visual Fidelity Audit — Next Improvement Slice

## Accepted focus

Prioritize the launch-critical **Visual Fidelity Audit** for the **Featured Launch Set** and catalog thumbnails before adding more fractal families or broad shader polish.

## Evidence checked

- `CONTEXT.md`: defines Featured Launch Set, Trust-Breaking First-Impression Defect, Visual Fidelity Audit, Seeded Thumbnail Palette.
- `TODO.md`: app icon visual sign-off and the full visual playtest audit remain open; catalog thumbnail improvements and continuous auto-zoom are marked complete.
- `docs/planning/PRD.md`: current policy keeps catalog thumbnails runtime-rendered, with no static catalog PNGs in the bundle. The 320×320 Launch Thumbnail Standard applies to launch-set thumbnail media outputs; 256×256 remains valid for staged smoke output.
- `integration_test/catalog/generate_gpu_thumbnails_test.dart`: stages 256×256 smoke output by default, can capture launch media at `LAUNCH_MEDIA_SIZE`, and has a separate opt-in catalog-asset write path (`UPDATE_CATALOG_THUMBS=true`) that is not the current shipping policy.
- `test/features/catalog/catalog_thumbnail_plan_test.dart`: protects exact asset mapping and approximate-preview labels.
- `assets/catalog_thumbs/`: the static thumbnail directory is absent in this checkout; `test/catalog/catalog_thumbnail_audit_test.dart` protects that state.
- `test/golden/failures/catalog_*` contains tracked failure-output images. `test/golden/catalog_golden_test.dart` passed all four phone/tablet dark/high-contrast cases in the inspected run; those stored artifacts were not reproduced by that run.

## Findings

### 1. Featured Launch Set manifest — resolved

The canonical list now exists as `kFeaturedLaunchSetModuleIds` in `lib/features/catalog/data/featured_launch_set.dart`. `test/features/catalog/featured_launch_set_test.dart` checks registry presence, exact thumbnail mapping, non-diagnostic modules, and controller selection.

The manifest is intentionally scoped for visual QA; the broader marketing set still has separate coverage requirements below.

### 2. Thumbnail standard — scope resolved

The owner confirmed that 320×320 applies to launch-set thumbnail media outputs, not bundled catalog thumbnails. `assets/AGENTS.md` and `test/catalog/catalog_thumbnail_audit_test.dart` continue to require the static catalog PNG bundle to remain absent; catalog thumbnails are rendered at runtime. The generator's `LAUNCH_MEDIA_SIZE=320` mode produces launch-set thumbnail-sized output under `build/test_output/launch_media/`; its default high-resolution capture remains 1080×1080. Staged smoke output may use 256×256. The separate `UPDATE_CATALOG_THUMBS=true` path can write catalog assets, but is not the current shipping policy.

Do not treat the opt-in catalog-asset write path as permission to add static catalog thumbnails. The 320×320 launch-media thumbnail target is not yet verified by a dedicated capture run.

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

Status: scope is documented and the generator supports it, but a 320×320 launch-media capture has not yet been verified.

Launch Thumbnail Standard:

- launch-set thumbnail media output: 320×320 PNG, generated under `build/test_output/launch_media/` with `LAUNCH_MEDIA_SIZE=320`
- staged generation smoke output: 256×256 PNG
- static catalog PNGs: not bundled; catalog thumbnails remain runtime-rendered
- separate high-resolution hero stills: 1080×1080 by default, configurable per capture run

Validation target: `LAUNCH_MEDIA_SIZE=320 ./scripts/capture-launch-media.sh` on a real GPU; confirm the report lists the Featured Launch Set entries at 320×320 with no failed renders. The catalog asset-update path is out of scope.

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
- [ ] rerun catalog/web smoke path and inspect the report
- [ ] record final Visual Fidelity Audit verdict

## Stop conditions

Do not do a broad shader rewrite. Do not add new fractal families until Slice A and Slice B pass. Do not bless visual output without deterministic seed, artifact paths, and metrics.
