# Flutter Fractal Forge — Execution TODO

> **Last comprehensive update:** 2026-08-25 recursive-object 3D expansion. Catalog counts below are reconciled to the current integrity test.
>
> **Source anchors for this refresh:** `test/catalog/catalog_id_integrity_test.dart` (545 escape-time entries, 1019 production fractals, 1 scientific visualization, and 1027 debug/test registry modules including 7 diagnostics), `lib/features/viewer/fractal_viewer_screen.dart` (controls HUD), `lib/core/services/rendering/palette_service.dart` + `palette_shader_adapter.dart` (palette textures).

## Goal coverage — visual-fidelity scope

<!-- goals:coverage:begin -->

Generated from `goals.json` by `goals.py render`. `met` requires an executed, passing check.

| Goal | Status | Evidence | Task |
| --- | --- | --- | --- |
| VIS-004: Verify the Featured Launch Set default and viewer-start flow | met | executed `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` → pass; inspection `TODO.md#VIS-004: prior real-GPU and viewer-start checks cover four modules` → pass | — |
| VIS-005: Reconcile the visual audit across Explore and the research library | met | executed `flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded (15 tests passed; includes live Explore inventory reconciliation)` → pass; executed `python research/fractals-library/scripts/validate_manifest.py` → pass; executed `python research/fractals-library/scripts/validate_visual_inventory.py` → pass; inspection `TODO.md#VIS-005: prior broad audit timed out and research definitions are not mapped` → fail | — |
| VIS-006: Audit mapped fractals in reconciled batches | partial | executed `CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; shader receives bailout=8; oracle skipped)` → pass; executed `CATALOG_THUMB_ONLY=core.lorenz_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-lorenz-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed=1/1/0; image 256x256, 641 colors, nonBlack=1.0)` → pass; executed `CATALOG_THUMB_ONLY=core.rossler_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-rossler-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; image 256x256, 1245 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; math oracle skipped: no reference oracle)` → pass; executed `FRESH 2026-10-06: CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, verdict pass)` → pass; executed `FRESH 2026-10-06: dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (0 changed) && flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (no issues) && python research/fractals-library/scripts/validate_visual_inventory.py (1027 Explore, 200 manifest; pass) && git diff --check (pass)` → pass; executed `FRESH 2026-10-06: flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 481 colors; verdict pass)` → pass; executed `VIS-006 scope closure check: requested all mapped Explore definitions and first-view behavior are not covered by this Four Wing-only batch` → fail; executed `dart format integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (Formatted 1 file; 0 changed)` → pass; executed `flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (No issues found)` → pass; executed `flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (core.four_wing runtime preview 384x346; 481 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass)` → pass; executed `flutter test integration_test/catalog/vis006_lorenz_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 3008 colors; nonBlack=1.0)` → pass; executed `flutter test integration_test/catalog/vis006_rossler_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 421 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass)` → pass; executed `git diff --check` → pass; executed `python -c "import json; d=json.load(open('docs/planning/visual-audit-inventory.json')); r=d['rows']; x=[i for i in r if i.get('source')=='Explore' and i.get('group')=='core']; captured=[i for i in x if i.get('runtime_preview','').startswith('captured in VIS-006:') or i.get('runtime_preview','').startswith('captured in VIS-006 ')]; print(f'Explore core rows={len(x)}; captured entries={len(captured)}; remaining={len(x)-len(captured)}'); assert len(captured)==len(x), 'VIS-006 has remaining mapped entries'" (exit 1: 1027 Explore core rows; 3 captured; 1024 remaining)` → fail; executed `python research/fractals-library/scripts/validate_visual_inventory.py (OK: 1027 Explore IDs + 200 manifest IDs; 1227 unique rows)` → pass; inspection `Inspected default and actual runtime-preview PNGs for core.four_wing: both are smooth broad color gradients with sharp sector/wedge boundaries, not a recognizable four-wing orbit; preserve formula pending follow-up` → fail; inspection `Lorenz captures show a narrow diagonal band over a smooth gradient rather than a recognizable two-lobed silhouette; visual follow-up warranted, formula preserved` → fail; inspection `Rossler defaults/runtime captures are mostly smooth gradients with a sharp triangular boundary rather than a recognizable orbit; additionally configured bailout=12 is normalized to 8 by shared parameter max=8 before shader uniform mapping; visual/default follow-up warranted, formula preserved` → fail; inspection `TODO.md#VIS-006: broad batch audit remains to be completed; Lorenz batch only captured` → fail | VIS-006 |
| SMOOTH-001: Prove smooth-coloring coverage for supported escape-time shaders | partial | executed `flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart` → pass; inspection `TODO.md#P1-3: four families (7 shaders) covered; complete applicable polynomial escape-time inventory remains open` → fail; inspection `docs/engineering/performance/SHADER_OPTIMIZATIONS.md` → pass | SMOOTH-001 |
| MEDIA-002: Select launch hero stills from qualified captures | unmet | inspection `TODO.md#MEDIA-002: owner selection remains open` → fail | MEDIA-002 |
| VIS-003: Obtain app icon visual sign-off | unmet | inspection `TODO.md#VIS-003: owner sign-off remains open` → fail | VIS-003 |
| DOC-PRD-001: Resolve which documents own active product scope | unverified | inspection `BLOCKERS.md#BLK-20261005-004: conflicting scope statements require owner decision` → fail | DOC-PRD-001 |

<!-- goals:coverage:end -->

---

## Architecture Direction (decided 2026-02-15, reaffirmed 2026-04-05)

**GPU-primary, CPU safety net.**
- GPU is the default renderer; many catalog modules share reviewed shader families rather than one shader per fractal
- Live registry lock: 545 escape-time catalog entries, 37 raymarched-3D entries, 9 custom hand-built modules, 1019 production fractals plus 1 scientific visualization (1027 debug/test `ModuleRegistry` modules including 7 diagnostics)
- CPU fallback auto-activates via renderer health/precision policy when GPU output or precision is invalid
- CPU path is maintenance-only (no further performance investment)
- GPU investment: coloring quality, smooth iteration, deep zoom, new formulas

---

## Perturbation Theory — Realistic Capability Assessment

**IMPORTANT:** Perturbation theory CANNOT be applied to all fractals. This section clarifies what's achievable.

### ✅ Perturbation Theory WORKS For (Polynomial Escape-Time)

These fractals use differentiable formulas where `dz_next = f(z+dz, c+dc) - f(z,c)` can be computed:

| Category | Fractals | Count | Status |
|----------|----------|-------|--------|
| Core Mandelbrot family | mandelbrot, multibrot variants | ~20 | 🔶 Mandelbrot uses DF2 path; multibrot3/4/5 perturbation implemented |
| Julia variants | julia, celtic_julia, buffalo_julia, etc. | ~30 | 🔶 Core `julia` perturbation implemented; variants remain open |
| Burning Ship variants | burning_ship, burning_ship_cubic, etc. | ~10 | 🔶 `burning_ship` implemented; variants remain open |
| Phoenix variants | phoenix, phoenix_julia | ~4 | 🔶 `phoenix` implemented; variants remain open |
| Buffalo/Tricorn/Celtic | buffalo, tricorn, celtic | ~6 | ✅ Implemented for core IDs |

**Current shipped GPU perturbation path:** `julia`, `burning_ship`, `buffalo`, `tricorn`, `celtic`, `phoenix`, `multibrot3`, `multibrot4`, `multibrot5`.
**Total achievable with perturbation: ~70-80 fractals**

### ❌ Perturbation Theory DOES NOT Work For

| Category | Reason | Examples |
|----------|--------|----------|
| IFS/Geometric | Uses iterated function systems, not escape-time | Sierpinski, Koch, Barnsley Fern |
| Strange Attractors | Continuous dynamics, not complex iteration | Lorenz, Rossler, Clifford |
| Cellular Automata | Discrete grid-based, not complex plane | Rule 30, Brian's Brain |
| Root-Finding fractals | Newton/Halley method, different algorithm | Newton z³-1, Halley |
| Stochastic | Random sampling, not deterministic | Buddhabrot, DLA |
| Tilings | Substitution rules, not iteration | Penrose, Ammann-Beenker |

**Most of the 1019-production-fractal catalog is still NOT suitable for perturbation; exact category counts need a fresh catalog audit.**

### 📊 Module Registry Breakdown (1019 production fractals; 1027 debug/test modules)

```
Live locks from test/catalog/catalog_id_integrity_test.dart:
├── Escape-time catalog raw unique IDs: 545
├── Raymarched-3D catalog IDs: 37
├── Custom hand-built modules: 9
├── Production fractals: 1019
├── Scientific visualizations: 1
└── Debug/test ModuleRegistry modules including diagnostics: 1027

Perturbation-capable target remains ~70-80 polynomial escape-time fractals.
Currently routed to GPU perturbation: 9 IDs (julia + 8 generic escape-time IDs).
Older 370-count planning rows are retired.
```

---

## P0 — MUST SHIP NEXT

**All open (unchecked) items in this section remain P0 until resolved.**

### P0-1: Critical Render Regressions

- [x] **GPU artifact at z≈5.10e+6** — Color blocks/grid artifacts appear despite perturbation shader ✅ FIXED 2026-04-05
  - **Root cause:** Delta overflow check in `escape_time_perturb_gpu.frag:165` used threshold `1e6` which was too aggressive
  - **Fix:** Changed threshold from `1e6` to `1e12` to avoid false triggers at deep zoom
  - **Verified:** All 350 fractals render correctly (fractal_render_audit_test.dart passed)

- [x] **FractalViewControls parameter mismatch** ✅ FIXED 2026-04-05
  - **Issue:** `fractal_viewer_screen.dart` called `FractalViewControls` with old parameter names
  - **Fix:** Updated to match current widget signature (`onOpenMoreActions` → removed, `onEnterFullscreen` → `onToggleFullscreen`)

- [x] **KIFS Menger Sponge stuck on "Loading shaders..."** — 3D fractal not loading ✅ FIXED 2026-04-05
  - **Root cause:** SkSL compiler doesn't support `%` operator on integers or `clamp(int, int, int)`
  - **Fix:** Replaced with integer-division modulo trick and `float(clamp(float(...)))` pattern
  - **Files fixed:** `shaders/quaternion_julia_2d_gpu.frag`, `shaders/menger_sponge_gpu.frag`, `shaders/menger_3d_slice_gpu.frag`
  - **Verified:** All 14 3D shaders compile successfully (shader_3d_diagnostic_test.dart passed)

- [x] **All 3D fractals broken** — Raymarching not working ✅ FIXED 2026-04-05
  - **Root cause:** Same SkSL incompatibility issues in 3D fractal shaders
  - **Fix:** Applied SkSL-compatible replacements to all affected 3D shaders
  - **Verified:** Build succeeds, all tests pass (864+ passed)

### P0-2: User-Reported Blockers (2026-02-25)

- [x] GPU→CPU fallback too slow when zooming deep; reduce hysteresis/threshold so CPU engages faster
- [x] **Controls too big/too intrusive** — Redesign for smaller, less cluttered UI ✅ 2026-06-06
  - Replaced modal bottom sheet (38% screen height) with semi-transparent HUD overlay
  - Game-like glass-morphism HUD with compact sliders, palette chips, and action buttons
  - Tap-outside-to-dismiss behavior (like game HUD)
  - Fractal visible and updating behind controls
  - New: `fractal_controls_hud.dart` overlay widget
  - Changed: viewer FAB toggles overlay instead of opening modal
  - Tests: 5 new HUD tests + all 18 existing controls tests pass
- [x] **3D fractals not working** — Investigate 3D pipeline/shaders and fix ✅ FIXED 2026-04-05
  - **Root cause:** SkSL `%` and `clamp(int, int, int)` not supported
  - **Fix:** See P0-1 items above
- **App icon visual sign-off** — adaptive launcher and store-art inputs exist; visual presentation acceptance remains open (details in Launch Visual Audit Handoff below).
- [x] **Improve catalog thumbnails** — Larger view size, higher-quality renders ✅ 2026-08-29
  - Raised bounded capture/decode width to 384 px with high-quality filtering
  - Increased thumbnail detail caps to 24 web / 40 native iterations and 24 colors
  - Added layout-aware cache keys so portrait grids never reuse square captures
- [ ] **Visual playtest audit** — cover both Explore groups and all 200 research-library definitions. Check true module defaults, runtime previews, and first viewer renders. Run CPU checks where a native CPU formula exists. Preserve formulas and log failures. Four-module evidence is partial. See `VIS-004` and `VIS-005` below.

### Visual Fidelity Audit — current queue

#### Now

- [x] **VIS-004 — Verify the Featured Launch Set viewer starts.** The real-GPU integration run verified configured default-view starts for `mandelbrot`, `burning_ship`, `phoenix`, `barnsley_fern`, `lorenz_2d`, `julia`, and `koch_snowflake`; the test also covers catalog search, viewer navigation, controls, and presets. Evidence: `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` (12 tests passed, GPU backend observed). `nova` and `newton_z3` still require separate launch-flow coverage under the broader visual audit.

- [x] **VIS-005 — Reconcile the complete visual-audit inventory.** Goal: visual playtest audit across both Explore groups and the research library. The inventory validator and catalog integrity test passed; see `goals.json` for executed evidence.
  - Goal: VIS-005.
  - Scope: map every Explore ID and all 200 definitions in `research/fractals-library/data/fractal_manifest.json` to an app module, shader, preview path, and CPU formula where one exists. Mark definitions with no app renderer as missing rather than treating them as rendered. Do not change formulas or implement missing modules during inventory.
  - Sources: `research/fractals-library/AGENTS.md`, `research/fractals-library/data/fractal_manifest.json`, `test/catalog/catalog_id_integrity_test.dart`, and [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md).
  - Acceptance: counts reconcile to both Explore groups and all 200 manifest IDs. Each ID has one explicit status and an artifact or mapping reference. Use `research/fractals-library/scripts/validate_manifest.py` as the manifest source check.
  - Dependencies: none. Ownership: repository backlog; check the active task ledger before dispatch.

**Remaining:** `VIS-006` — audit the mapped modules and definitions in bounded batches. Compare module defaults, runtime previews, and first viewer renders. Run CPU checks where a native CPU formula exists. Reconcile selected, generated, and failed counts for each batch. Lorenz and Rossler default/runtime previews are captured; neither produces a recognizable attractor silhouette on inspection. Rossler's configured bailout (12) is reduced to 8 by the shared parameter schema max, and its math oracle is unavailable (no reference oracle for this family). The timed-out 1,020-entry run is not completion evidence. Record the final verdict only after the requested scope is reconciled.

#### Next

- [ ] **VIS-006 — Audit mapped fractals in reconciled batches.** Goal: complete the visual playtest audit after the inventory is mapped.
  - Scope: audit mapped Explore and research-library entries in bounded batches. Compare configured defaults, runtime previews, and first viewer renders; run CPU checks only where a native CPU formula exists. Preserve formulas and record failures/artifact paths.
  - Sources: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md), `research/fractals-library/data/fractal_manifest.json`, and VIS-005 inventory output.
  - Acceptance: each batch reconciles selected, generated, and failed counts and links every result to an ID and artifact or explicit unsupported status. No full-audit verdict until all requested entries are accounted for.
  - Dependencies: VIS-005. Ownership: repository backlog; check active work before starting.

- [ ] **SMOOTH-001 — Prove smooth-coloring coverage for supported escape-time shaders.** Goal: smooth escape-time coloring without visible banding.
  - Scope: inspect `docs/engineering/performance/SHADER_OPTIMIZATIONS.md` and run/add focused regression coverage for the shader families named there. Do not change shader formulas or claim every shader is covered without inventory evidence.
  - Acceptance: an executed focused test covers each currently declared applicable family and reports no banding regression; update the documented coverage from that evidence.
  - Sources: `PRD.md` quality criteria, `TODO.md` P1-3, and `docs/engineering/performance/SHADER_OPTIMIZATIONS.md`. Dependencies: none.

- [x] GPU deep zoom not switching to CPU at all; adjust fallback thresholds/hysteresis
- [x] **Panning bugs at high zoom** — Fixed 2026-08-12 by migrating
  camera/render vectors from Float32-backed `vector_math` to
  `vector_math_64`; verified at `1e12` zoom and from viewport-edge gestures
  (`fractal_view_state_test.dart`, `fractal_renderer_gesture_test.dart`)
- [x] **Auto-zoom not continuous** — fixed: zero-dwell transitions between zoom legs; elapsed-time animation, speed changes, and interruption/resume are covered by auto-explore service/planner tests ✅ verified 2026-10-03
  - **Verified:** `flutter test test/features/auto_explore/auto_explore_service_test.dart test/features/auto_explore/auto_explore_zoom_planner_test.dart` (48 tests passed)

## Launch Visual Audit Handoff

Canonical plan: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md). The thumbnail decision is resolved: 320×320 launch-set thumbnail media outputs, no static catalog thumbnail bundle; 256×256 staged smoke is allowed. High-resolution hero stills remain a separate configurable output.

### Now

None: the current Featured Launch Set Chromium smoke and 320×320 GPU capture gates are complete. Remaining launch-media selection and icon visual sign-off require product-owner judgment.

### Blocked / Needs decision


- [ ] **MEDIA-002 — Select launch hero stills.** Scope: choose 6–8 from the captured Featured Launch Set plus separate 3D/tiling candidates (`mandelbulb` and `spectre_monotile` or `hat_monotile`); no source asset publication. Acceptance: record the selected module IDs and artifact paths, covering 2D escape-time, Newton, IFS, attractor, tiling, and one 3D example as required by the runbook. Dependency: candidate output from MEDIA-001 and supplemental high-resolution captures must exist. Blocker: selection is taste-based and requires product-owner judgment; owner not recorded. See [`docs/planning/LAUNCH_MEDIA.md`](docs/planning/LAUNCH_MEDIA.md).
  - Goal: MEDIA-002.
- [ ] **VIS-003 — App icon visual sign-off.** Scope: inspect the existing adaptive launcher and store artwork in representative device masks; do not treat missing files as the issue or redesign without approval. Acceptance: product owner records accept/request-change and any exact crop/design correction. Blocker: visual acceptance criteria/approval are owner-controlled; inputs and dimensions were checked, but visual acceptance is not claimed. Ownership: owner decision required.
  - Goal: VIS-003.

### Done

- [x] **WEB-001 — Run the Featured Launch Set Chromium smoke.** The exact filtered Chromium smoke passed all nine modules with zero failures or warnings; independent review confirmed the runtime regression fixture and smoke result. Evidence: native task `t_411791c4`, review run 135; reports `test/results/catalog-smoke-chromium.json` and `test/results/playwright-results.json`.
- [x] **MEDIA-001 — Verify 320×320 launch-thumbnail captures.** Forwarded `FORCE_GPU_RENDER=true` to avoid the integration placeholder, then captured all nine Featured Launch Set images on the AMD Radeon RX 6800 XT. All nine PNGs are 320×320 with zero failed renders and zero `qualityWarnings`; each render audit passed. Evidence: native task `t_8b02fb11`, run 165; `build/test_output/launch_media/thumbnail_report.json`. The descriptive launch metric flags `barnsley_fern` as near-black (mean luminance 12.9604, dark-pixel ratio 0.9365); this is not a formal quality warning and remains relevant to owner selection.
- [x] **VIS-000 — Correct thumbnail policy and classify catalog golden artifacts.** PRD and CONTEXT now reflect the resolved 320×320 launch-media scope; runtime catalog rendering remains the shipped policy. The audit plan records the tracked golden-failure images separately from the four passing golden comparisons.

## Documentation scope questions

### Blocked / Needs decision

- [ ] **DOC-PRD-001 — Reconcile current product-scope ownership.** Goal: resolve `BLK-20261005-004` and identify whether root `PRD.md` or the current backlog/README owns active scope where they differ. Default applied: treat conflicting, unimplemented root-PRD items as historical until revalidated; do not add product scope meanwhile. Scope: documentation and goal records only; no feature implementation. Acceptance: owner chooses A or B in `BLOCKERS.md`, then the PRD/backlog mark each affected item as active, deferred, or out of scope with consistent links. Source: [`PRD.md`](PRD.md), [`docs/planning/PRD.md`](docs/planning/PRD.md), and [`BLOCKERS.md`](BLOCKERS.md). Ownership: repository backlog.

### P0-3: Dynamic Iteration Adjustment

- [x] Increase max iteration slider beyond 500 (now 5000)
- [x] Automatically raise iteration count when zooming in (adaptive step-up)
- [x] Adaptive logic: start low, progressively increase based on zoom growth
- [x] Convergence detection: compare previous frame, stop when changes < threshold
- [x] Works on both GPU and CPU fallback paths

---

## P1 — HIGH PRIORITY (Deep Zoom & GPU Quality)

### P1-1: Perturbation Theory Improvements

#### P1-0: Escape-Time Shader SkSL Fix (COMPLETED 2026-04-05)
- [x] **Escape-time shader GPU compilation fix** — 204 shaders had SkSL-incompatible `%` operator
  - **Root cause:** SkSL doesn't support `%` (modulo) operator on integers
  - **Fix:** Replaced `x % N` with `x - (x / N) * N` across all affected shaders
  - **Files fixed:** All shaders with `(schemeInt - 50) % 4` palette cycling
  - **Verified:** `buffalo_gpu.frag` now compiles on GPU (previously failed)
  - **Impact:** All escape-time fractals now render correctly on GPU instead of falling back to CPU

#### P1-1a: Fix Perturbation Artifact Bug (COMPLETED 2026-04-05)

- [x] Raised perturbation overflow threshold from `1e6` to `1e12` in `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`
- [ ] Follow-up only if artifacts recur: replace discontinuous fallback with smoother reference-orbit transition

#### P1-1b: Extend Perturbation to Julia Variants

**Target Fractals (Priority Order):**
- [x] `julia` - core Julia (2026-07-02: flat-render bug fixed; unified into
  escape-time wrapper via julia mode, `julia_perturb_module.dart` deleted)
- [x] `celtic_julia`, `buffalo_julia`, `burning_ship_julia`, `tricorn_julia`
  (2026-07-02: julia-mode flag reusing base deltas)
- [x] 26 preset-c julias (`f0143`-`f0176` series) routed as z²+c julia mode
- [ ] `phoenix_julia`, cubic/power/trig/perpendicular variants — need new
  shader deltas; deferred (see spec Out of scope)

**Implementation:**
- Julia variants use `uExtra2` shader flag: `dz0 = pixel offset`, `dc = 0`
- Each variant reuses its base formula's existing delta function (no new deltas)
- All julia variants now routed through unified `escape_time_perturb_module`
- `kJuliaVariantSpecs` table maps catalog IDs to (base formula, fixed c)
- F-series preset julias read `juliaCReal`/`juliaCImag` from module params

**Files:**
- `lib/core/modules/escape_time_perturb_module.dart` (unified wrapper + variant table)
- `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` (julia mode flag)
- `lib/features/renderer/policy/precision_ladder_policy.dart` (routing gate)
- `lib/features/renderer/policy/render_plan.dart` (resolver simplification)
- Deleted: `lib/core/modules/julia_perturb_module.dart`

#### P1-1c: Add Period Detection for Reference Orbit (COMPLETED 2026-07-02)

- [x] **Period detection shipped** in `computeEscapeTimePerturbOrbitBytes`
  (`lib/core/modules/escape_time_perturb_module.dart`)
  - Detects approximate cycles (eps 1e-9, max period 64) with a
    consecutive-pair confirmation so Phoenix's `(z, z_prev)` state is safe
  - On detection, stops iterating and fills the orbit texture tail by
    repeating the cycle bytes (byte-identical for exact cycles, ≤1 LSB for
    attracting cycles)
  - Orbit computation extracted to a pure, GPU-free testable function
  - **Verified:** `test/perturb_orbit_period_test.dart` (exact 1- and
    2-cycles byte-identical vs full iteration; chaotic center has no false
    positives; escaping center unchanged)

- [x] **Julia orbit encoding bug fixed 2026-07-02** — `julia_perturb_module.dart`
  still used the old 16-bit packing that mismatched the shader's 24-bit decode,
  degrading the Julia reference orbit to ~8 effective bits (decode error
  ~1.7e-2 vs intended ~4.8e-7). Now delegates to `packPerturbOrbitComponent`.
  **Verified:** `test/julia_perturb_orbit_encoding_test.dart`

### P1-2: Series Approximation (Deep Zoom Speedup)

**What it does:** Precompute early iterations as polynomial series, skip actual iteration when safe.

**Performance gain:** 10x-100x speedup at extreme zoom.

#### P1-2a: Series Approximation on GPU

**Implementation Approach:**
```glsl
// Add to escape_time_perturb_gpu.frag
uniform sampler2D uSeriesCoeffs;  // Texture with precomputed coefficients
uniform int uSeriesLength;         // Number of terms

vec2 computeSeries(vec2 dc, int n) {
    // Evaluate polynomial using Horner's method
    // Z_n ≈ sum_{k=0}^{N} a_k * dc^k
}

void main() {
    // ...
    for (int n = 0; n < MAX_ITERS; n++) {
        if (n < uSeriesLength && dc_magnitude_small) {
            Z_n = computeSeries(dc, n);  // Skip iteration
        } else {
            Z_n = fetchOrbit(n) + deltaIterate(n, dc);  // Full perturbation
        }
    }
}
```

**Files to Create:**
- `lib/core/modules/series_approximation.dart` — Coefficient computation

**Files to Modify:**
- `shaders/escape_time_perturb_gpu.frag`
- `lib/core/modules/escape_time_perturb_module.dart`

#### P1-2b: Series Approximation on CPU

**Implementation:**
```dart
// Compute series coefficients during reference orbit calculation
List<Complex> computeSeriesCoefficients(Complex c, int terms) {
    // a_0 = 0
    // a_1 = 1 (for Mandelbrot)
    // a_2 = 2*z_1
    // a_3 = 2*z_2 + 2*z_1^2
    // ... derive recursively
}
```

### P1-3: Smooth Coloring in ALL Shaders

**Current State:** Smooth-coloring code appears in multiple shaders, including `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`. No complete inventory or regression test verifies coverage across the applicable polynomial escape-time shader set.

**Target:** Audit all applicable polynomial escape-time shaders and add or confirm formula-appropriate smooth coloring. The earlier estimate of approximately 80 shaders has not been rechecked.

**Example Formula:** This expression is used by the perturbation shader. Check each recurrence and magnitude value before applying it to another shader.
```glsl
float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
```

**Shader Files to Audit:** (Priority order; these are review targets, not confirmed failures)
1. `shaders/legacy/escape_time/mandel_step_smooth.frag`
2. `shaders/legacy/escape_time/julia.frag`
3. `shaders/legacy/escape_time/burning_ship.frag`
4. Applicable files under `shaders/escape_time_family/`

See [`docs/engineering/performance/SHADER_OPTIMIZATIONS.md`](docs/engineering/performance/SHADER_OPTIMIZATIONS.md) for current coverage limits and checks.

### P1-4: Arbitrary Precision for Extreme Zoom (CPU)

**Current Limit:** Double precision ~1e12 with df2 shader, then arbitrary precision CPU.

**Implementation Options:**

| Approach | Pros | Cons |
|----------|------|------|
| Integer arrays (base 10^9) | Fast, portable | Complex implementation |
| `decimal` package | Easy | Slow, large numbers |
| MPFR bindings | Fast, proven | Native code, complex |

**Recommended:** Custom integer array implementation for performance.

**Files to Create:**
- `lib/core/math/big_decimal.dart` — Arbitrary precision arithmetic
- `lib/core/math/big_complex.dart` — Complex number with BigDecimal

### P1-5: True Plane Anchors (AR-Ready)

**From PRD:** "Integrate true plane anchors (vertical + horizontal)"

**Implementation:**
1. Detect dominant line/plane in fractal boundary via edge detection
2. Anchor navigation to detected geometry
3. Enable "tap to place" on fractal boundaries

**Status:** Not started, deferred.

---

## P2 — IMPORTANT PRODUCT POLISH

### P2-1: GPU Visual Quality

- [ ] **Smooth coloring** in all escape-time shaders (see P1-3)
- [x] **Palette texture system** — Pass palette as texture uniform
- [ ] **Color cycling animation** — Perturbation shader supports time shift; roll out beyond perturbation path
- [x] **User palette selection** — Select from viewer controls
- [ ] **Regression test** — Assert no banding artifacts

### P2-2: UI/UX Improvements

- [x] **Controls redesign** — HUD overlay shipped (`FractalControlsHud`)
- [ ] **Controls snap/collapse** — More aggressive
- [ ] **Overflow menu** — Move non-critical actions
- [ ] **Auto-pilot improvements** — Smooth path, dwell behavior
- [x] **Manual corrections** — Auto-explore yields to continuous gestures,
  adopts the corrected zoom/direction, and replans one-shot wheel/keyboard
  corrections (`auto_explore_service_test.dart`)

### P2-3: Preset & Export

- [ ] **Preset thumbnails** — Auto-generate on save
- [x] **Custom palettes** — Save/load gradients
- [ ] **Bookmarks** — Save coordinates + formula + palette
- [ ] **Share presets** — One-tap Instagram/X/WhatsApp
- [ ] **Frame lock** — Exact viewer-to-export fidelity

### P2-4: Catalog Hardening

- [x] Registry covers 545 escape-time entries + 37 raymarched 3D + shared/custom promotions = 1019 production fractals plus 1 scientific visualization (1027 debug/test modules including diagnostics)
- [ ] **PRD manifest loader** — `assets/catalog/prd_catalog.json`
- [x] ID lock/integrity tests
- [x] Filter/sort + list/grid toggle
- [x] Persist catalog view mode
- [x] **Add 4+ new formulas** — Catalog has grown beyond the old 370 baseline

### P2-5: Export Hardening

- [x] Export pauses auto-navigation
- [x] Separate Save vs Share
- [ ] **Resume policy prompt** — After export
- [ ] **Share QA** — WhatsApp/Instagram/X/gallery

---

## P3 — ENHANCED DEEP ZOOM (Googol-Scale)

### P3-1: Googol-Scale Architecture (10^100+)

**Target:** Enable zoom beyond 10^100.

**Components Required:**

| Component | Status | Files |
|-----------|--------|-------|
| Arbitrary precision math | 🔶 Planning | `big_decimal.dart`, `big_complex.dart` |
| Reference orbit (big float) | 🔶 Planning | `escape_time_perturb_module.dart` |
| Series approximation (GPU) | 🔶 Planning | `series_approximation.dart` |
| Delta iteration (big float) | 🔶 Planning | `escape_time_perturb_gpu.frag` |
| Period detection | 🔶 Planning | `escape_time_perturb_module.dart` |

### P3-2: Perturbation for All Polynomial Fractals

**Target:** ~80 fractals total with perturbation support.

**Progress:**
- Currently routed: 9 IDs (`julia` + 8 generic escape-time IDs)
- Julia variants: ~30 candidates (core `julia` done; variants still open)
- Other polynomial: ~40 candidates

**To Implement:**
1. Add delta formulas for all unique polynomial patterns
2. Create universal perturbation wrapper
3. Add to `kPerturbableEscapeTimeIds`

### P3-3: Chunked Rendering for Extreme Zoom

**Why:** At googol-scale, single-frame render may be too slow.

**Solution:** Tile-based parallel rendering with edge feathering.

```dart
// Divide viewport into NxN tiles
// Render tiles in parallel
// Stitch with edge blending
class ChunkedRenderer {
    List<ui.Image> tiles;
    Future<void> renderTile(int x, int y);
    ui.Image stitchTiles(List<ui.Image> tiles);
}
```

---

## P4 — NEW FRACTAL FORMULAS

### P4-1: New Escape-Time Fractals

- [x] **Target met:** Catalog grew beyond the old 370 baseline to 1014 production fractals.
- [ ] Next formula work should be quality-gated: only add researched formulas with tests, stable IDs, and shader assets.

### P4-2: New 3D Fractals

- [x] 3D shader compatibility blockers fixed.
- [ ] Next 3D work should prioritize visual QA and thumbnails over raw count.

---

## COMPLETED ITEMS

### Deep Zoom
- [x] Perturbation theory shader (9 routed IDs: Julia + 8 generic escape-time IDs)
- [x] Double-float shader (`mandelbrot_df2.frag`) for 5e6-1e12
- [x] Reference orbit cache (LRU singleton)
- [x] Deep zoom precision policy with hysteresis
- [x] Dynamic iteration scaling with zoom

### Rendering
- [x] GPU-primary with CPU fallback
- [x] Tile-based CPU renderer (96px, spiral, cancel-on-gesture)
- [x] Smooth coloring in perturbation shader
- [x] Palette texture support + cached sampler adapter
- [x] **Batched orbit-texture rasterization** (2026-07-02) — shared
  `rasterizePerturbOrbitBytes` (one `drawVertices` call) replaces the
  per-pixel `drawRect` loops duplicated in both perturbation modules
  (~4,000 draw ops per navigation step → 1; measured 3.33ms → 1.38ms per
  build at max iterations). Byte-exactness locked by
  `test/perturb_orbit_texture_test.dart` (software rasterizer) and
  `integration_test/rendering/perturb_orbit_texture_gpu_test.dart`
  (real GL pipeline; run with `-d linux`, needs `xvfb-run` when headless)

### Quality
- [x] 64 palette support + selector
- [x] Screen-reader labels
- [x] GPU→CPU threshold tuning
- [x] Catalog integrity tests

### Testing
- [x] Focused TODO refresh checks passed: catalog integrity, controls HUD, palette texture/cache tests
- [x] 19 integration test files
- [x] Golden tests (phone/tablet × dark/highContrast)
- [x] Semantic audit

---

## CPU PATH — MAINTENANCE ONLY

**Policy:** No further performance investment.

**Maintained for:**
- Emulator testing
- Broken GPU fallback
- Extreme zoom beyond GPU capability

**Current capabilities:**
- Double precision
- Tile-based progressive rendering
- 2x2 AA refine pass
- Smooth escape-time coloring

---

## OUT OF SCOPE

- **Arenaton** — Not part of this repo
- **Video recording** — Deferred
- **Runtime shader compilation** — Deferred
- **User-defined formulas** — Deferred (would require interpreter)

---

## FILE MANIFEST

### Critical Files to Modify

| File | Change | Priority |
|------|--------|----------|
| `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` | Add smoother fallback / series approx if needed | P1 |
| `lib/core/modules/escape_time_perturb_module.dart` | Period detection, more polynomial IDs | P1 |
| `lib/core/modules/builders/escape_time_catalog.dart` | Add perturbation configs | P1 |
| `lib/features/renderer/policy/precision_ladder_policy.dart` | Threshold tuning | P2 |
| `lib/features/renderer/cpu/cpu_fractal_renderer.dart` | BigDecimal support | P3 |

### Files to Create

| File | Purpose | Priority |
|------|---------|----------|
| `lib/core/modules/series_approximation.dart` | Series coeff computation | P1 |
| `lib/core/math/big_decimal.dart` | Arbitrary precision | P3 |
| `lib/core/math/big_complex.dart` | Big complex number | P3 |
| `lib/core/modules/perturbation_catalog.dart` | Universal perturbation builder | P3 |

---

## RESEARCH SOURCES

### Perturbation Theory
- K.I. Martin — "Perturbation techniques for the Mandelbrot set"
- Fractalforums.com — "Perturbation Theory" (1000+ posts)
- Deepzoom.com — Practical perturbation implementation

### Series Approximation
- Paul Derbyshire — "Optimizing Mandelbrot Computation"
- Smart Internet — Series approximation algorithms

### Implementation References
- FractInt — Classic fractal software (C, historical)
- KFract — Open source perturbation
- Mandelbrot Explorer — Modern Windows app

---

## SUCCESS CRITERIA

| Milestone | Verification |
|-----------|--------------|
| No artifacts at z=5.10e+6 | Visual test, screenshot comparison |
| 3D fractals render | Launch app, navigate to Mandelbulb |
| Julia perturbation | Zoom Julia to 1e10, verify smooth |
| Series approx 10x speedup | Benchmark frame time before/after |
| Googol-scale zoom | Zoom to 10^50, verify no precision loss |

---

## NOTES

- **Perturbation ≠ Universal** — Only ~80/370 fractals can use it
- **IFS/Attractors/Cellular** — Require completely different deep zoom strategies (if any)
- **Series approximation** — Only helps when zoomed into areas that escape late
- **Period detection** — Critical for stability at extreme zoom
