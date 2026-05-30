# CPU Renderer / Formula Refinement Candidates (opensource-informed)

Date: 2026-02-18  
Scope: audit `/opensource` for CPU-side refinement opportunities, then map to current CPU path in `lib/features/renderer/*`.

---

## Sources reviewed

### Open-source references
- `opensource/repos/renderers/DeepDrill/src/ddrill/Driller.cpp`
  - multi-round glitch recovery (`perturbation.rounds`), tolerated bad pixels, probe-point validation, period/attractor checks.
- `opensource/repos/renderers/FractalShark/HpSharkFloatLib/PeriodicityChecker.h`
  - explicit `PeriodFound` / `Escaped` / `Continue` states, derivative-aware periodicity checks.
- `opensource/repos/renderers/FractalShark/FractalSharkGpuLib/ScaledKernels.cuh`
  - perturbation re-scaling thresholds (`test1ab`, `testw2`, `w2threshold`) for stability.
- `opensource/repos/renderers/FractalShark/FractalSharkGpuLib/AntialiasingKernel.cuh`
  - explicit antialiasing pass with configurable AA grid.
- `opensource/repos/renderers/kf2/fraktal_sft/calculate_perturbation.cpp`
  - hybrid/perturbation path, derivatives, scaled reference handling.
- `opensource/repos/renderers/kf2/fraktal_sft/reference.cpp`
  - scaled-reference storage to avoid underflow loss points.
- `opensource/repos/renderers/kf2/fraktal_sft/main_formula.cpp`, `.../opengl.h`
  - jitter controls (`seed`, shape, scale) for anti-alias quality.
- `opensource/repos/renderers/kf2/fraktal_sft/hybrid.h`
  - formula/hybrid evaluation + dynamic re-scaling thresholds.
- `opensource/repos/renderers/giulia/src/app/renderer.cpp`
  - runtime precision-mode switching (single vs double path).

### Current repo files examined
- CPU path:
  - `lib/features/renderer/cpu_formulas.dart`
  - `lib/features/renderer/cpu_iterators.dart`
  - `lib/features/renderer/cpu_fractal_renderer.dart`
  - `lib/features/renderer/cpu_render_isolate.dart`
- Renderer policy:
  - `lib/features/renderer/deep_zoom_precision_policy.dart`
  - `lib/features/renderer/fractal_renderer.dart`
- Module plumbing:
  - `lib/core/modules/module_registry.dart`
  - `lib/core/modules/phoenix_module.dart`
  - `lib/core/modules/nova_module.dart`
  - `lib/core/modules/builders/escape_time_catalog.dart`
- Tests / audits:
  - `test/cpu_formula_coverage_test.dart`
  - `test/fractal_render_audit_test.dart`
  - `test/iteration_buffer_golden_test.dart`

---

## Key audit findings (current CPU path)

1. **Formula parity coverage is still mostly synthetic**
   - Current module universe (escape-time configs + custom registry IDs): **338 IDs**.
   - CPU status snapshot:
     - **33 native** implementations
     - **165 mapped synthetic** implementations (`_cpu_synthetic(...)`)
     - **140 dynamic synthetic fallback** (ID not mapped; `cpuFormulaForModuleId` hashes moduleId)
   - This is the largest correctness parity gap.

2. **Coverage tests can pass without mathematical correctness (coverage-style false confidence)**
   - `cpu_formula_coverage_test.dart` only enforces:
     - “different from Mandelbrot by >5% pixels”
     - “non-black ratio >1%”
   - `fractal_render_audit_test.dart` allows proxy metrics and structure-only checks.
   - `cpu_iterators.dart` exposes only a few true iterators; many modules use luminance/hash proxies.

3. **CPU render output is not color/feature parity with GPU**
   - CPU formula API has no `colorScheme`, no `transparentBackground`, no module-specific extras (e.g. Phoenix `phoenixP`, Nova `relaxation`).
   - `CpuFractalRenderer` always reads `bailout`; for Nova this mismaps shader semantics (`uRelaxation` on GPU).
   - Inside color uses a hardcoded blue (`_insideColor = (46,120,220)`), while many GPU shaders render interior black/transparent.

4. **Deep zoom CPU strategy is plain double only**
   - No periodicity/bulb/cardioid interior checks in CPU hot loop.
   - No CPU perturbation + series approximation + glitch recovery path (DeepDrill/KF2/FractalShark style).
   - This limits correctness stability in ultra-deep CPU-only workflows.

5. **AA quality path is basic fixed-grid supersampling only**
   - 1x preview / 2x2 refine; no adaptive edge AA, no jitter/blue-noise patterning.
   - `sampleCount` is converted via `sqrt(...).round()`, so non-square counts (e.g. 8) resolve unexpectedly.

---

## Prioritized bugfix/refinement backlog

## P0 — Fix CPU parity plumbing (params + color semantics)

**Why first:** native formulas still mismatch GPU behavior because CPU path drops important runtime semantics.

**Refinement scope**
- Extend CPU formula contract to include module params context (at minimum: color scheme + module-specific extras).
- Handle custom params:
  - Phoenix: `phoenixCReal`, `phoenixCImag`, `phoenixP`
  - Nova: `relaxation` (do not alias to bailout)
- Align interior behavior with GPU (black/transparent behavior).
- Add optional linear→sRGB step parity (or explicitly document CPU color model differences if intentional).

**Open-source cue:** giulia runtime precision-path separation (`renderer.cpp`) demonstrates explicit mode-dependent behavior, not silent parameter overloading.

**Effort:** **M**

**Suggested tests**
- Param-sensitivity tests: changing `phoenixP` / `relaxation` must change CPU output deterministically.
- Color mode parity tests for representative formulas (`mandelbrot`, `julia`, `phoenix`) across `colorScheme` values.
- Inside/interior expectation tests (black vs transparent) per module flags.

---

## P0 — Replace synthetic fallback for critical formulas used in deep zoom and presets

**Why first:** current fallback can show plausible but mathematically wrong images.

**Start set (high impact)**
- `phoenix` (currently dynamic synthetic)
- `multibrot4`, `multibrot5` (currently mapped synthetic)
- `mandelbrot_de`, `julia_de`, `mandelbrot_stripe_avg` (currently unresolved)

Then expand in waves by usage frequency and catalog prominence.

**Open-source cue:** KF2 hybrid/formula engine (`calculate_perturbation.cpp`, `hybrid.h`) shows scalable formula differentiation instead of hashed placeholders.

**Effort:** **M** (initial wave), **L** (broad rollout)

**Suggested tests**
- Per-formula canonical-point tests (known in/out points, expected iteration relations).
- Per-formula image digest suite (small canonical views, stable hash budget with tolerance).
- “No synthetic on critical set” guard test.

---

## P0 — Replace coverage-style tests with correctness tests

**Why first:** current suite can pass while formulas are wrong.

**Refinement scope**
- Upgrade `cpu_formula_coverage_test.dart` from “different enough image” to math/parity assertions.
- Add explicit “no proxy iterator allowed” list for audited formulas.
- Require true iterator buffer for formulas included in golden/deep-zoom audits.

**Open-source cue:** DeepDrill’s explicit glitch/probe workflow and FractalShark’s explicit periodicity states emphasize correctness-state testing, not just visual entropy.

**Effort:** **M**

**Suggested tests**
- GPU-vs-CPU iteration buffer comparison at controlled shallow zoom (for formulas with native CPU implementation).
- Canonical escape/bounded assertions per formula family.
- Test that synthetic/proxy paths are never used for the P0 critical formula set.

---

## P1 — Add true iterator metrics for more formulas (remove luminance/hash proxies)

**Why:** current iterator proxies weaken render audits and deep-zoom diagnostics.

**Refinement scope**
- Implement true `CpuIterator` for formulas currently proxy-backed in audits.
- Keep proxy only as explicit temporary fallback with reporting.

**Effort:** **M**

**Suggested tests**
- Expand `iteration_buffer_golden_test.dart` beyond the current small core set.
- Add regression guard: audited formulas must return true iterator path, not `_proxyFromColor`.

---

## P1 — AA quality upgrade: adaptive supersampling + deterministic jitter

**Why:** fixed 2x2 often misses fine boundary quality; non-square sample counts are currently ambiguous.

**Refinement scope**
- Replace sqrt/round sample derivation with explicit sample pattern sets.
- Add adaptive AA (edge-triggered 1x→4x/8x).
- Add deterministic jitter option (seeded, stable, non-shimmering) for banding reduction.

**Open-source cue:**
- FractalShark AA kernel (`AntialiasingKernel.cuh`)
- KF2 jitter controls (`main_formula.cpp`, `opengl.h`)

**Effort:** **M**

**Suggested tests**
- Grain/edge quality benchmark tests (existing `computeGrainScore` + new edge sharpness metric).
- Determinism test: same seed/view => identical output hash.
- “AA level actually applied” unit tests for sample patterns.

---

## P1 — Add periodicity + interior short-circuit checks in CPU loop

**Why:** improves both performance and correctness stability in bounded regions.

**Refinement scope**
- Mandelbrot cardioid/main-bulb fast inclusion checks on CPU path.
- Periodicity checking state in escape loops (continue / periodic / escaped).

**Open-source cue:**
- DeepDrill area/period checks (`Driller.cpp`)
- FractalShark `PeriodicityChecker.h`

**Effort:** **S–M**

**Suggested tests**
- Performance microbench on interior-heavy views.
- Correct classification tests for known periodic points.

---

## P2 — CPU deep zoom stability path: perturbation + series + glitch rounds

**Why:** plain double escape-time is not sufficient for extreme zoom CPU correctness.

**Refinement scope**
- Add CPU perturbation reference-orbit path for Mandelbrot first.
- Add series approximation skip + probe validation.
- Add glitch retry rounds / bad-pixel budget.

**Open-source cue:**
- DeepDrill `Driller.cpp`
- KF2 `calculate_perturbation.cpp`, `reference.cpp`, `hybrid.h`
- FractalShark scaled perturbation kernels

**Effort:** **L**

**Suggested tests**
- Deep zoom landmark suite (1e12, 1e14, 1e18+) with iteration stability checks.
- Glitch budget test: unresolved pixel ratio below configured threshold.
- Cross-run determinism at fixed precision mode.

---

## P2 — Precision tiering for CPU (double → double-double / scaled)

**Why:** enables graceful accuracy scaling instead of hard failure at deep zoom.

**Refinement scope**
- Introduce numeric tier policy similar to “single/double path switching” ideas.
- Add optional high-precision backend for extreme zoom windows.

**Open-source cue:**
- giulia precision mode switching (`renderer.cpp`)
- KF2 reference type variants and scaled representations (`reference.cpp`)

**Effort:** **L**

**Suggested tests**
- Precision tier handoff tests (no visual discontinuity spikes across threshold).
- Numeric error budget comparisons against high-precision reference points.

---

## Recommended execution order

1. **P0 parity plumbing (params + interior/color semantics)**
2. **P0 critical formula de-synthetic wave** (`phoenix`, `multibrot4/5`, DE/stripe set)
3. **P0 test-suite hardening (remove coverage-style false positives)**
4. **P1 true iterators + AA upgrade + periodicity checks**
5. **P2 deep-zoom perturbation/series + precision tiering**

---

## Notes relevant to maintainers

- Existing documentation underestimates the current synthetic/proxy surface area in places; align docs to measured status before rollout.
- Keep synthetic fallback only as an explicit temporary compatibility mode with telemetry, not as silent default correctness path.
- Prefer narrow, formula-family waves with locked tests over broad “implement many formulas at once” batches.
