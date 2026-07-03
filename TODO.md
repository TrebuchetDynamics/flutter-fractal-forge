# Flutter Fractal Forge — Execution TODO

> **Last comprehensive update:** 2026-07-02 catalog/status refresh from live tests and source.
>
> **Source anchors for this refresh:** `test/catalog_id_integrity_test.dart` (501 escape-time entries, 974 production fractals / 981 debug-test registry modules including 7 diagnostics), `lib/features/viewer/fractal_viewer_screen.dart` (controls HUD), `lib/core/services/rendering/palette_service.dart` + `palette_shader_adapter.dart` (palette textures).

---

## Architecture Direction (decided 2026-02-15, reaffirmed 2026-04-05)

**GPU-primary, CPU safety net.**
- GPU is the default renderer; many catalog modules share reviewed shader families rather than one shader per fractal
- Live registry lock: 501 escape-time catalog entries, 10 raymarched-3D entries, 7 custom hand-built modules, 974 production fractals (981 debug/test `ModuleRegistry` modules including 7 diagnostics)
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

**Most of the 974-production-fractal catalog is still NOT suitable for perturbation; exact category counts need a fresh catalog audit.**

### 📊 Module Registry Breakdown (974 production fractals; 981 debug/test modules)

```
Live locks from test/catalog_id_integrity_test.dart:
├── Escape-time catalog raw unique IDs: 501
├── Raymarched-3D catalog unique IDs: 10
├── Custom hand-built modules: 7
├── Production fractals excluding diagnostics: 974
└── Debug/test ModuleRegistry modules including diagnostics: 981

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
- [ ] **App icon overhaul** — Adaptive icon + Play Store asset needed
- [ ] **Improve catalog thumbnails** — Larger view size, higher-quality renders
- [ ] **Visual playtest audit** — Test every fractal (GPU + CPU), log failures
- [x] GPU deep zoom not switching to CPU at all; adjust fallback thresholds/hysteresis
- [ ] **Panning bugs at high zoom** — Precision/gesture/transform issues
- [ ] **Auto-zoom not continuous** — Navigation too slow at high zoom levels

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
1. [x] `julia` — Core Julia set (`julia_perturb_module.dart`)
2. [ ] `celtic_julia`, `buffalo_julia`, `burning_ship_julia`
3. [ ] `tricorn_julia`, `perpendicular_julia`
4. [ ] `multibrot3_julia` through `multibrot12_julia`
5. [ ] `phoenix_julia`

**Implementation:**
- Julia uses `deltaJulia()` formula (already in shader, no dc term)
- Core `julia` is routed separately by `RendererPlanModuleResolver`
- Variant support still needs catalog IDs mapped to perturbation formula handling

**Files to Modify:**
- `lib/core/modules/julia_perturb_module.dart`
- `lib/core/modules/escape_time_perturb_module.dart`
- `lib/core/modules/builders/escape_time_catalog.dart` (add perturbation configs)

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

**Current State:** Only `escape_time_perturb_gpu.frag` has smooth coloring.

**Target:** Add smooth coloring to all polynomial escape-time shaders (~80).

**Standard Formula:**
```glsl
// Smooth escape-time coloring
float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
float t = fract(smoothVal / 64.0);
```

**Shader Files to Update:** (Priority order)
1. `shaders/mandelbrot_gpu.frag`
2. `shaders/julia_gpu.frag`
3. `shaders/burning_ship_gpu.frag`
4. All `*_gpu.frag` in `shaders/` for escape-time fractals

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
- [ ] **Manual corrections** — Accept pan/zoom while auto runs

### P2-3: Preset & Export

- [ ] **Preset thumbnails** — Auto-generate on save
- [x] **Custom palettes** — Save/load gradients
- [ ] **Bookmarks** — Save coordinates + formula + palette
- [ ] **Share presets** — One-tap Instagram/X/WhatsApp
- [ ] **Frame lock** — Exact viewer-to-export fidelity

### P2-4: Catalog Hardening

- [x] Registry covers 501 escape-time entries + 10 raymarched 3D + shared/custom promotions = 974 production fractals (981 debug/test modules including diagnostics)
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

- [x] **Target met:** Catalog grew beyond the old 370 baseline to 974 production fractals.
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
| `lib/core/modules/julia_perturb_module.dart` | Maintain core Julia perturbation path | P1 |
| `lib/core/modules/builders/escape_time_catalog.dart` | Add perturbation configs | P1 |
| `lib/features/renderer/deep_zoom_precision_policy.dart` | Threshold tuning | P2 |
| `lib/features/renderer/cpu_fractal_renderer.dart` | BigDecimal support | P3 |
| `lib/core/modules/mandelbulb_module.dart` | 3D fix | ✅ DONE - SkSL issues in shaders fixed |

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
