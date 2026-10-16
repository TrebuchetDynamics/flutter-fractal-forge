# Visual Fidelity Audit — Next Improvement Slice

## Accepted focus

Status: Accepted

Authority: the owner-approved visual-improvement scope recorded below and in `BLOCKERS.md` resolution `BLK-20261005-002`. Documentation maintenance does not authorize dispatch or new product scope.

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

The visual inventory reconciles 1,028 Explore IDs (core=1,028; performance=0) and 200 research-manifest IDs. It records default capture/runtime-preview evidence for 187 Explore rows; 841 remain uncaptured. All 200 research rows are `missing_app_renderer`. The `first_view` field is populated for 14 Explore rows. `cpu_formula` is `not audited` in 1,145 of 1,228 rows. These are recorded inventory values, not fresh artifact checks. The validator checks references and shader paths, not render quality. Remaining coverage is tracked in [`TODO.md`](../../TODO.md).

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

## Current execution frontier

- Now: retain the active `VIS-006` worker. `VIS-006-BATCH-20` is Next and depends on that worker's completion. These capture slices do not complete first-view or CPU coverage.
- Next: `VIS-006-FIRST-VIEW-04` checks five captured modules after batch 20; `VIS-006-CPU-01` then checks five native CPU formulas. Keep unsupported research rows explicit; this plan does not authorize their implementation.
- Independent Now: `SMOOTH-001-INVENTORY-01` reconciles the integer-power family and the uncovered Multibrot d=4 assertion. `SMOOTH-001-INVENTORY-02` is its accepted coverage successor under TODO P1-3. Completed sample tasks stay done.
- Needs decision: `DOC-PRD-001`, `MEDIA-002`, and `VIS-003` remain owner-controlled. Root-PRD scope conflicts do not become implementation commitments.

Decision: preserve existing worker ownership and priorities, and add qualification successors rather than reopening completed batches. Evidence: current inventory and the failed d=4 coverage assertion. Check: canonical ledger validation, body/status reconciliation, and consumer backlog gate. Readiness is not dispatch authorization.

Skill application: `planning-and-task-breakdown` produced bounded Now/Next bodies with explicit dependencies and observable checks. `documentation-and-adrs` kept implementation, historical receipts, and current qualification separate. No new architectural decision was needed.

## Stop conditions

Do not do a broad shader rewrite. Do not add new fractal families until Slice A and Slice B pass. Do not bless visual output without deterministic seed, artifact paths, and metrics.


## Quality without losing variety

Status: Accepted

Accepted scope: the owner's `/autoresearch plan` request asks for a quality-improvement plan that preserves variety. Existing accepted visual scope permits demonstrated bug fixes and formula-preserving default/render tuning. This section accepts those outcomes and documentation/backlog work only. The proposed discovery layout and promotion rubric below are recommendations, not owner-approved UI or numerical release gates. No implementation, new worker, timed schedule, priority change or publication is authorized by this planning pass.

### Evidence and diagnosis

The current inventory records 1,028 unique Explore rows, 187 rows with captured default/runtime evidence, 841 without that evidence, and 14 with executed first-view records. The 200 research definitions remain `missing_app_renderer`. These are recorded metadata counts, not fresh render checks or proof that the remaining items are bad. The owner reports low quality; this pass did not independently score the whole catalog.

`CatalogRepository.fromRegistry` exposes registered modules rather than a quality-ranked selection. `CatalogEntry` has stable IDs and source-based mathematics, but no end-to-end visual qualification. `FractalMathematics` already separates families, relationships and identity qualifications. Reuse those facets: a named preset, exponent or color variant does not automatically count as a distinct mathematical family. The nine-entry Featured Launch Set is an audit manifest, explicitly not a catalog ranking. Six entries belong to complex iteration/root-finding; it alone cannot stand for 3D, tilings or cellular/stochastic variety.

The existing Launch Visual Metrics are descriptive. A nonblank, colorful image can still be poorly framed, repetitive, mathematically misleading or unresponsive. Do not maximize color counts or relax strict health thresholds to make a batch pass. Image health, visual judgment, mathematical identity, interaction, performance and export need separate evidence.

### Recommended approach

1. Preserve the entire supported catalog and all IDs, favorites, history, presets and deep links. Change discovery emphasis, not availability. Keep existing diagnostic exclusions. No deletion, forced migration or renaming is needed.
2. Run a small family-stratified pilot before auditing all remaining items for taste. Start with existing Featured Launch Set evidence, then include 3D, tiling and cellular/stochastic representatives from the current registry. Cap the pilot at 12 existing IDs. Record the exact selected families/groups and why each is distinct; record any family that has no qualified representative rather than silently omitting it.
3. Repair the three most consequential demonstrated first-impression defects first. Prefer default framing, useful safe presets, palette/readability and accurate labels. Change formulas only for a reproduced implementation error with a mathematical regression test. Do not introduce new catalog IDs merely to offer better starting views. Capture before/after at identical viewport, seed, backend and settings.
4. Proposed discovery: a small curated starting collection using existing catalog filters/cards, with the full catalog one explicit action away and still searchable. Use one or two representatives per reviewed family rather than a wall of close variants. Reuse existing source-reviewed groups to make variants understandable; do not infer equivalence from shared shader paths or similar screenshots. No recommendation service, remote analytics, new dependency or ranking framework.
5. Proposed promotion rule: every curated entry needs readable framing, a truthful source-based description/qualification, working pan/zoom and at least one useful parameter change, honest preview behavior, bounded performance on named targets, and a PNG matching the selected view. Visual approval must cite the artifact and a concrete reason. An inspired or approximate system may qualify as an experience with explicit disclosure; it never becomes a certified mathematical implementation because it looks good.
6. Proposed intake policy: new catalog expansion should add a distinct experience and pass the same entry checks; improving an existing entry is preferred to adding another near-duplicate. Do not impose a blanket freeze on the separately authorized Gaussian work or cancel existing workers. No new numerical FPS/latency threshold is accepted here; measure p50/p95 and retain existing performance protections before proposing a target.

### Measurements and bounded execution plan

Use two dimensions, never raw catalog size as success:
- Quality: number of pilot entries with all documented experience gates supported by artifact/check receipts. Baseline is NOT_MEASURED; target is all selected pilot entries, at most 12. Define the final review rubric in `CAT-QUALITY-01` before an optimization run. Do not call missing evidence a quality failure.
- Variety/compatibility guards: unchanged supported catalog ID set and persistence resolution, plus no loss of reviewed mathematical-family/group coverage in the pilot. Report family coverage separately from entry count. Show multiple attractive starting configurations without manufacturing more mathematical identities.

A runnable metadata proxy today counts executed first-view records: baseline 14, higher is better. This is coverage only, not the quality metric. Verify: `python3 -c 'import json; x=json.load(open("docs/planning/visual-audit-inventory.json")); print(sum(r.get("source")=="Explore" and r.get("first_view","").startswith("executed") for r in x["rows"]))'`. Planning dry-run printed 14. Retain this proxy only for coverage; replace it with the agreed pilot gate count before a quality optimization run.

Guard commands for later implementation: `python3 research/fractals-library/scripts/validate_visual_inventory.py`; `flutter test test/catalog/catalog_id_integrity_test.dart test/catalog/catalog_repository_test.dart test/catalog/catalog_mathematical_navigation_test.dart test/catalog/catalog_search_widget_test.dart test/catalog/catalog_screen_a11y_test.dart --reporter expanded`; `flutter analyze`. Real GPU defaults/runtime/first-view and physical PNG journeys remain separate gates via existing VIS-006 and REL-JOURNEY tasks. These product guards were NOT_RUN in this docs-only pass. Suggest two repair iterations per selected defect, maximum six iterations, then compare the same artifacts and stop if there is no improvement. No loop starts now.

### Queue and ownership

- Reuse `VIS-006`, `VIS-006-BATCH-20`, `VIS-006-FIRST-VIEW-04` and `VIS-006-CPU-01` for existing capture/first-view/CPU qualification. Do not duplicate their work or reinterpret completed image-health batches as taste approval.
- `CAT-QUALITY-01`: assess a diverse pilot and bind defects to evidence. Independent of full-catalog capture completion; reuse available receipts and request only missing pilot checks.
- `CAT-QUALITY-02`: repair three demonstrated pilot defects after that assessment. Keep each repair independently reversible with focused regression checks. Native platform claims require actual platform evidence.
- `CAT-QUALITY-03`: proposed curated discovery, Needs decision. Requires a qualified pilot and approval of the discovery/promotion proposal. The existing `MEDIA-002` remains the separate owner-selected marketing stills task, not a duplicate curation task.
- Current owner order is viewer corrections under focus `VIEW-UI-001`, then CAT-QUALITY-01 and CAT-QUALITY-02, as recorded in PRD.md#quality-first-planning-priority. Preserve existing task IDs, completed/local review evidence and live leases. Curated discovery remains Proposed/Needs decision. This priority decision does not authorize implementation or scheduling.

Decision: preserve breadth and improve defaults plus selective discovery; Evidence: registry-backed exposure, existing source-based facets, partial first-view inventory; Reason: deletion loses compatibility, while another broad capture sweep alone does not address framing, interaction or honest identity; Check: pilot before/after evidence plus stable-ID and family coverage guards.

Graph evidence: fresh 38-file code-only Graphify scan in `/home/xel/.hermes/profiles/fractal/cache/scratch/catalog-quality-plan-b5706ec3/graphify-out/graph.json`; 778 nodes, 1,130 edges. Queries: `CatalogRepository CatalogEntry FractalMathematics featured launch thumbnail LaunchVisualMetrics`, and `CatalogRepository CatalogEntry`. Source corroboration: `CatalogRepository` at `catalog_repository.dart:15,20,57`, `CatalogEntry` at `catalog_entry.dart:12,30`, `FractalMathematics` at `fractal_mathematics.dart:11,45`, and Featured Launch Set at `featured_launch_set.dart:3-18`. Coverage is partial: shaders, viewer/export internals, semantic docs and full mathematical proof are unindexed; queries truncate, five self-loops and duplicate-label warnings remain. No missing/dangling endpoints were reported. Graph topology is not quality evidence.

Skill application: planning-and-task-breakdown bounds assessment, three repairs and optional discovery without duplicating capture tasks. Documentation-and-adrs records the outcome/proposal distinction and compatibility tradeoff in this existing owner; no ADR is needed for a reversible discovery recommendation. Graphify scopes the catalog/facet/metrics seam, corroborated in source. The STE-inspired profile preserves quantities, qualifications and unrun checks in the new prose.


## OpenAI mathematics visual candidate shortlist

Status: Proposed

Authority: the owner requests candidates from https://github.com/openai/math through `/autoresearch plan`. This authorizes research and queue persistence, not approval of new catalog modules, numerical gates, implementation, commits or timed scheduling. Respect the preceding quality-over-quantity plan: shortlist three distinct experiences, prefer extension over duplicate IDs, and pick at most one proof-of-concept after an owner choice. Existing focus/order/leases stay unchanged.

### Source snapshot and verification limits

Upstream pinned commit: `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`. Read the full CONTENTS index and candidate sections 148, 223, 224, 230 and 155; read formalization scope documents 148/230/155 and the opening model/result sections of manuscripts 148/230/224. Downloaded PDFs and exact source receipts remain under `/home/xel/.hermes/profiles/fractal/cache/scratch/openai-fractal-candidates-924511e6`. PDF extraction for 148 initially failed in read_file but pdftotext recovered its defining equations. These are source-backed proposals, not independently verified breakthroughs or proven performance. No Lean rebuild or complete proof review ran. Formalization scope can be narrower than the manuscript: 230's scope documents positivity of the explicit gauge, not the whole finite-positive-measure claim. 224's near-critical manuscript explicitly assumes its companion critical Cardy result; do not present it as independently unconditional.

### Ranked candidates

1. **Self-similar measure and overlap explorer (result 148)** — best bounded first candidate. Render weighted finite affine contractions on the real line, `f_i(x)=r_i*x+t_i`, with intervals and a zoomable density strip. Let users compare separated maps, unequal/signed contractions and exact overlaps. This is directly self-similar fractal mathematics, unlike another named escape-time variant. Reuse/extend a suitable existing Cantor/IFS identity if it can preserve its meaning; `cantor_set` and `cantor_dust` already exist. A new ID is justified only for genuinely new weighted-overlap behavior.
   - Source: [self-similar measure paper](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/The-entropy-rate-dimension-formula-for-self-similar-measures-on-the-line-September-24-2026/main.pdf), [formalization scope](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/lean/docs/148.md).
   - Key distinction: measure dimension, attractor dimension and finite sampled histogram are different. The stated formula is `min(1,h_RW/chi)`, with entropy of composed affine maps, not simply entropy of branch choices. Exact coinciding compositions must aggregate probabilities. Do not display `H(p)/chi` as certified for overlapping inputs; dimension one does not imply absolute continuity. Use rational exact fixtures for overlap checks, label arbitrary floating-input estimates approximate.
   - Planned proof fixtures: ordinary separated Cantor measure; unequal branch weights; repeated identical generators produce the same measure rather than inflated entropy; negative contractions reflect correctly. Bound iterations/samples and cancel before stale results publish. Attractive framing and useful presets must pass CAT-QUALITY criteria before promotion.

2. **Seeded Schramm–Loewner curve explorer (result 230, related 223)** — strongest genuinely new curve family. Show a finite numerical chordal SLE trace driven by Brownian motion, with a visible seed, kappa and discretization controls. The half-plane model uses `d g_t(z)/dt = 2/(g_t(z)-sqrt(kappa)*B_t)`; its trace is not an arbitrary random walk with that label. Approximate trace recovery needs a reviewed numerical scheme, bounded steps and convergence fixtures before catalog admission.
   - Sources: [SLE gauge paper](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/An-exact-Hausdorff-gauge-for-SLE-September-25-2026/An-exact-Hausdorff-gauge-for-SLE-September-25-2026.pdf), [230 formalization scope](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/lean/docs/230.md), result 223 in [CONTENTS](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/CONTENTS.md).
   - Different kappa values are presets of one mathematical family, not separate catalog items. For `0<kappa<8`, explain the theoretical dimension `1+kappa/8` without claiming a finite polyline has that measured dimension. The dimension relation predates the new gauge work; this is not an OpenAI-invented fractal. Do not offer an exact Hausdorff-gauge readout computed from finite raster pixels.
   - Planned checks: zero-driving vertical-slit limit as a numerical fixture, deterministic seed replay, refinement/error comparison, finite outputs at allowed parameters, cancellation, bounded memory and matching exported trace. The zero-driving fixture is a test limit, not part of the paper's strict positive-kappa theorem. No explicit SLE/Loewner entry was found in inspected module sources/inventory; this is a scoped negative lookup, not a proof against every alias.

3. **Poisson–Voronoi percolation crossing explorer (result 224)** — visually strong, but extend existing work rather than add another procedural texture. Display finite randomly seeded Voronoi cells, coupled occupancy slider, connected clusters and a highlighted left-to-right crossing. Geometry and per-cell uniform marks remain fixed while probability changes: a cell is occupied iff `U_i <= p`. This lets users see a connectivity transition instead of merely changing color noise.
   - Sources: [near-critical manuscript](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/From-critical-crossings-to-quenched-near-critical-universality-in-Voronoi-percolation-October-5-2026/critical-crossings-quenched-near-critical-universality-voronoi-percolation.pdf), [critical companion](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/Cardys-formula-for-critical-Poisson-Voronoi-percolation-September-23-2026/paper.pdf).
   - Overlap: current `percolation` uses hashed square occupancy plus a capped random walker; that shader does not compute exact cluster connectivity. `voronoi_fractal_crackle` is a separate procedural texture. Do not silently relabel either as Poisson–Voronoi percolation, replace saved shader state, or claim lattice and Voronoi thresholds agree. Decide an explicit finite-model extension/version before any source change. Preserve both existing IDs.
   - Planned checks: exact cell adjacency/crossings on tiny independent fixtures; no false crossing through clipped boundary adjacency; increasing p with the same marks never removes occupied cells; seed reproducibility; finite-domain clipping labels; performance bounds and accurate frozen-state export. A finite window/sample supports exploration, not the continuum universality theorem. Boundary guards around Poisson sampling need an explicit approximation disclosure.

### Reuse, defer and reject

- Gaussian moat is already accepted under `GAUSS-MOAT-001` and uses `gaussian_prime_lattice`; reuse the existing MAP/WALK/GROWTH/QUALIFY tasks. No second prime lattice task.
- Result 155, translational aperiodic tile in Z3: defer. Interesting finite voxel/tiling exploration, but not inherently a fractal, and a finite crop cannot establish absence of periodic tilings. Extracting the actual tile and completion rules is materially more work than a decorative voxel shader. Existing tiling catalog entries are not substitutes for this construction.
- Falconer distance/Kakeya: potential educational geometry overlays, not ready standalone fractal definitions. Matrix multiplication, Riemann-zeta breakthroughs and proof titles alone do not justify new catalog entries. No invented OpenAI Mandelbrot formula.

### Next decision, measurement and guards

Recommend choosing the self-similar measure explorer first, with SLE next if adding a genuinely new curve experience matters more than reusing IFS. Keep the Voronoi proposal third due to existing identities and geometry/connectivity complexity. The three proposal tasks remain Needs decision. Implementation/qualification tasks are created or reused only after selecting a candidate and accepting its finite-model contract; do not book three new renderer projects merely because three papers exist.

Metric for this planning pass: shortlisted candidates with pinned source, distinct finite model, overlap check, disclosure and planned discriminating tests. Verify the three corresponding task bodies and scope notes; baseline before this pass 0 candidate records, after 3. This is planning completeness, not visual quality. Execution metric after approval: one selected experience meeting the six CAT-QUALITY gates, not growth in catalog size. Product Guard commands are planned: `flutter test test/catalog/catalog_id_integrity_test.dart test/catalog/catalog_repository_test.dart --reporter expanded`, `flutter analyze`, mathematical model fixtures, deterministic before/after images and named-platform PNG checks. These product checks are NOT_RUN. Suggest at most three finite-model proof-of-concept iterations for the selected candidate; stop on absent correctness or unacceptable measured cost rather than ship a lookalike. No loop runs now.

Graph evidence: fresh partial seven-file code-only Graphify graph at `/home/xel/.hermes/profiles/fractal/cache/scratch/openai-fractal-candidates-924511e6/graphify-out/graph.json`, 86 nodes/96 edges; query `CatalogRepository FractalMathematics ModuleRegistry` source-correlated nodes at catalog_repository:15, module_registry:64 and fractal_mathematics:11. Query truncated, duplicate label warning; catalog declarative entries are poorly represented structurally, so source/inventory lookup corroborates overlap. Shader/proof semantics and complete viewer/export dependencies are unindexed. No graph-derived certification. Skill application: planning-and-task-breakdown retains proposals outside executable Now/Next and defines one candidate choice; documentation-and-adrs records the mathematical/approximation boundaries here without an ADR; repo-docs synchronizes the queue without altering prior priorities.


### Expanded candidates — additional source-backed proposals

Status: Proposed

The owner asked for more candidates. Preserve the initial three IDs and ranking; these four append to the proposal queue, not the executable backlog. Upstream main is unchanged at the pinned commit below. These are established mathematical models discussed by the manuscripts, not fractals invented by OpenAI. An infinite-limit theorem does not make every finite image a certified fractal.

#### OAI-VIS-04-UST — Uniform spanning tree and loop-erased path explorer

- Source: result 231, [pinned manuscript](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/The-free-uniform-spanning-forest-is-a-factor-of-IID-September-25-2026/The-free-uniform-spanning-forest-is-a-factor-of-IID-September-25-2026.pdf) and [index](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/CONTENTS.md).
- Proposed image/model: Seeded branching trees, a highlighted unique path and animated loop erasure on a capped finite grid. Wilson sampling is an established finite uniform-spanning-tree approach; the paper concerns the free spanning forest on infinite graphs, not a new finite algorithm.
- Distinctness/overlap: No explicit spanning-tree/loop-erased ID matched the recorded inventory. Maze CA, brownian_tree_dla and levy_brownian_paths exist, but neither maze rules nor diffusion-limited aggregation is a uniform spanning tree. Do not substitute DLA or relabel an existing identity.
- Planned checks: Every vertex belongs to one acyclic connected tree, edge count V-1, unique paths; exact tiny-graph enumeration checks the sampling law, replay same seed, disclose rooting/free/wired boundary choice, cancel long walks and cap walk work without silently biasing accepted samples. Retain bounded compute/cancellation, EN/ES and accessible controls, same-state PNG output and CAT-QUALITY promotion checks. All are NOT_RUN.
- Recommendation: Strong new branching/curve experience; best of this extension to consider first.

#### OAI-VIS-05-DIMER — Double-dimer nested-loop explorer

- Source: result 226, [pinned manuscript](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/The-curve-scaling-limit-of-half-plane-double-dimers-September-23-2026/paper.pdf) and [index](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/CONTENTS.md).
- Proposed image/model: Draw two independent perfect matchings of a bounded bipartite lattice, then their superposition: doubled edges and closed loops. Color by loop identity/nesting and retain the two matchings for inspection. The cited paper proves a half-plane Temperleyan scaling limit; generic finite rectangles are not automatically that law.
- Distinctness/overlap: No dimer ID matched the inventory. Related to SLE/CLE but distinct finite perfect-matching model; keep it one entry, not one catalog item per loop color.
- Planned checks: One matched edge per vertex in each matching, degree two with multiplicity in the superposition, doubled edges treated separately, loop decomposition exhausts remaining edges and small exact matchings check sampling. Distinguish exact uniform sampling from a finite MCMC approximation; report burn-in/convergence limitations rather than claim uniformity. Retain bounded compute/cancellation, EN/ES and accessible controls, same-state PNG output and CAT-QUALITY promotion checks. All are NOT_RUN.
- Recommendation: Strong nested-loop/fractal-limit candidate; sampling correctness is the main feasibility risk.

#### OAI-VIS-06-HEIGHT — Six-vertex height and contour explorer

- Source: result 225, [pinned manuscript](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/The-Gaussian-free-field-limit-of-the-balanced-six-vertex-model-with-variance-multiplier-1-over-arcsin-c-over-2-September-23-2026/The-Gaussian-free-field-limit-of-the-balanced-six-vertex-model-with-variance-multiplier-1-over-arcsin-c-over-2-September-23-2026.pdf) and [index](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/CONTENTS.md).
- Proposed image/model: Show lattice arrows, a finite discrete height map and contour bands for the ice model. Enforce two arrows in and two out at every interior vertex; display a=b=1 and c weight, boundary conditions and sector. Result 232 supplies a related triangular-Lipschitz-height variant, grouped here rather than booked separately.
- Distinctness/overlap: No six_vertex/height/gaussian_free ID matched. Ordinary procedural noise is not a Gaussian free field or an ice-model sampler. Similar colors do not establish equivalent mathematical identity.
- Planned checks: Ice constraints hold; oriented height increments are path-consistent under the stated boundary/sector convention; tiny configurations have correct weights; seed replay and sampler limitations are disclosed. A torus can have nonzero winding, so do not claim a globally periodic scalar height outside a zero-winding sector. Finite height samples are not exact continuum GFF samples. Retain bounded compute/cancellation, EN/ES and accessible controls, same-state PNG output and CAT-QUALITY promotion checks. All are NOT_RUN.
- Recommendation: Fractal-adjacent rough surface with scale-rich contours, not a deterministic self-similar fractal. Defer until sampler and boundary contract are tractable.

#### OAI-VIS-07-FK — Fortuin–Kasteleyn cluster and interface explorer

- Source: result 223, [pinned manuscript](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/Square-lattice-FK-interfaces-and-nested-loops-for-1-leq-q-lt-4-September-23-2026/paper.pdf) and [index](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/CONTENTS.md).
- Proposed image/model: Finite square-lattice random-cluster configurations with visible bond probability p, cluster weight q, clusters, boundary wiring and exploration interface. The finite law weights configurations by p^open*(1-p)^closed*q^clusters; it is not independent percolation when q differs from one. Treat q=1 and q=2 as configurations of one family.
- Distinctness/overlap: Existing percolation is not this finite random-cluster law; coordinate with OAI-VIS-03-VORONOI and preserve its ID. It also relates to OAI-VIS-02-SLE but finite lattice connectivity is a different model. Reuse a future common model only if justified by real callers, not a speculative graph framework.
- Planned checks: Tiny exact partition-function/cluster-count fixtures, q=1 reduction to independent bonds, correct wired/free cluster counting and Dobrushin interface rules, seed replay and explicit sampler mixing gaps. Do not infer arbitrary-q uniformity or SLE convergence from a colorful sample. The inspected first paper covers 1<=q<4; the index lists broader companions, whose hypotheses must be reviewed separately. Retain bounded compute/cancellation, EN/ES and accessible controls, same-state PNG output and CAT-QUALITY promotion checks. All are NOT_RUN.
- Recommendation: Fractal-limit cluster/interface candidate, higher cost and overlap than UST. No separate Ising or q-specific catalog explosion.

### Related extensions, not more catalog IDs

- Result 153 Bernoulli convolutions: add a named two-map family to OAI-VIS-01-IFS if selected. Show finite random series/distributions versus lambda with separated, touching and overlapping regimes. Reuse that existing proposal ID. Finite density strips cannot certify singularity/absolute continuity or an infinite arithmetic approximation condition. [Source](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/Arithmetic-classification-and-non-Pisot-singularity-for-Bernoulli-convolutions-October-3-2026/paper.pdf).
- Result 146 standard map: existing core.standard_map and named configurations already appear in inventory. Recommend a future source-reviewed orbit/Poincare-section improvement, not another entry; phase portraits are chaos visualizations, not automatically self-similar fractals. This extension inspected index scope only, not the 146 proof.
- Result 212 first-passage growth: optional educational arrival-time/path mode adjacent to OAI-VIS-03-VORONOI/percolation, not a new fractal proposal. Positive random edge weights and shortest travel-time fronts differ from occupied-site connectivity. A finite shortest-path tree does not prove absence of infinite bigeodesics. [Source](https://github.com/openai/math/blob/fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb/preprints/No-bigeodesics-in-planar-first-passage-percolation-September-24-2026/main.pdf).

### Extension evidence and quality boundary

Read fresh pinned CONTENTS sections 231/226/225/223/232/153/212 and 231's formalization scope. Retrieved PDFs 226/225/223 and inspected their abstracts/model scope; this is not a full proof audit. 225 explicitly concerns a variance (squared multiplier), not an amplitude; its balanced-torus/plane law must not be conflated with arbitrary finite boundary data. No Lean rebuild, sampled images, distributions, sampler-performance or numerical convergence tests ran.

A recorded-inventory identifier search found no explicit spanning/Wilson/loop-erased/dimer/six-vertex/height/GFF/random-cluster/Ising strings, but found maze, DLA, Brownian-path and standard-map entries. This is scoped alias evidence, not exhaustive proof of nonexistence. The earlier three proposal tasks and CAT-QUALITY task IDs are reused.

Graph evidence: fresh four-file code-only Graphify extraction under `/home/xel/.hermes/profiles/fractal/cache/scratch/openai-fractal-more-f4f9a4dd/graphify-out/graph.json`, 80 nodes/90 edges. Query `ModuleRegistry FractalMathematics CatalogRepository` is source-correlated at module_registry:64, fractal_mathematics:11 and catalog_repository:15. Truncated query/duplicate-label warning; full shader/model/docs semantics remain unindexed. Inventory and source corroboration control candidate overlap rather than graph inference.

Planning metric: four additional complete proposal records, seven total under OAI-VIS-001; this counts source/model/check/disclosure records, not implemented or visually qualified entries. Verify canonical task/body bindings and preservation of prior IDs/order. Baseline extension records=0, target=4. Later product Guards remain the original shortlist's mathematical fixtures, catalog identity tests, analyzer and named-platform render/export checks, all NOT_RUN. Recommend a maximum of three bounded proof-of-concept iterations for one owner-selected candidate, never concurrent implementation of all seven. Selection, finite-model acceptance and measured quality precede any implementation handoff. No scheduling/dispatch/commit authority is added.
