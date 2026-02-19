# GPU Refinement Candidates (low-risk, shader-focused)

Date: 2026-02-18
Scope requested: audit `/opensource` (especially `shader-fractals`, `FractalShark`, `kf2`, `giulia`) and propose **concrete, low-risk** shader refinements for current repo.

---

## Sources reviewed

### Open-source references
- `opensource/kf2/gl/kf.frag.glsl`
  - palette LUT interpolation + smoothing (`KF_Palette`, `KFP_Smooth`)
  - deterministic dithering (`dither`)
  - flexible iteration transforms (`KF_IterTransform`, DE/log/loglog/sqrt)
- `opensource/FractalShark/FractalSharkGpuLib/ScaledKernels.cuh`
  - perturbation re-scaling / re-basing thresholds (`test1ab`, `testw2`, `w2threshold`)
- `opensource/FractalShark/HpSharkFloatLib/PeriodicityChecker.h`
  - explicit periodicity vs escaped vs continue state
- `opensource/FractalShark/FractalSharkGpuLib/LowPrecisionKernels.cuh`
  - precision tiers and compile-time iteration batching
- `opensource/giulia/src/app/renderer.cpp`
  - explicit precision-mode switching (single/double)
- `opensource/giulia/src/gl/shaders/double_precision.shader`
  - separate high-precision path

### Current repo files examined
- Shader hot paths:
  - `shaders/mandel_step_smooth.frag`
  - `shaders/julia_gpu.frag`
  - `shaders/burning_ship_gpu.frag`
  - `shaders/mandelbrot_df2.frag`
  - `shaders/escape_time_perturb_gpu.frag`
  - `shaders/mandelbrot_de_gpu.frag`
- Dart/render plumbing:
  - `lib/core/modules/builders/escape_time_builder.dart`
  - `lib/core/modules/escape_time_perturb_module.dart`
  - `lib/core/modules/julia_perturb_module.dart`
  - `lib/features/renderer/deep_zoom_precision_policy.dart`
  - `lib/features/renderer/fractal_renderer.dart`

---

## Key audit observations

1. **Iteration-cap mismatch exists**
   - Most shaders are hard-capped at `MAX_ITERS = 500` (repo-wide scan: 349 shaders at 500, 1 at 2000), while UI/policy paths can drive much higher values (`maxIterations=5000`, `gpuMaxIterations=2000`).
2. **Perturb shader smooth coloring is not power-aware**
   - `escape_time_perturb_gpu.frag` supports Multibrot3/4/5 formulas but uses quadratic smoothing form unconditionally.
3. **Derivative work is done even when not needed**
   - In key shaders, derivative updates run every iteration even for regular palettes where normal-map modes are inactive.
4. **Core Mandelbrot optimizations are not consistently propagated**
   - `mandel_step_smooth.frag` includes cardioid/bulb short-circuit; `mandelbrot_df2.frag` and `mandelbrot_de_gpu.frag` do not.
5. **Perturb orbit encoding uses fixed clamp `[-4,4)`**
   - In Dart orbit caches, this can clip reference orbit values for some formulas/regions.
6. **Palette banding mitigation is limited**
   - Current palette phase is smooth but lacks tiny deterministic dithering seen in kf2-style pipelines.

---

## Prioritized patch candidates

## P1 — Align iteration caps to actual shader limits (very low risk)

**Why:** Prevents wasted parameter scaling and avoids user-facing “iterations > actual GPU loop bound” mismatch.

**Current files:**
- `lib/features/renderer/deep_zoom_precision_policy.dart`
- `lib/features/renderer/fractal_renderer.dart`
- `lib/core/modules/builders/escape_time_builder.dart`

**Patch idea:**
- Add module/path-aware GPU cap:
  - standard escape-time path: `500`
  - perturbation path (`escape_time_perturb_gpu.frag`): `2000`
- Clamp before writing shader uniform, not only in-shader.
- Optional: lower `EscapeTimeConfig.maxIterations` default from 5000 to 500 (or leave UI as-is but clamp sent value strictly).

**Expected impact:** correctness/UX consistency + minor perf/telemetry clarity.

**Risk:** low.

---

## P1 — Make perturb smooth coloring power-aware (low risk, quality fix)

**Why:** `escape_time_perturb_gpu.frag` handles Multibrot3/4/5 but smooth formula is currently quadratic-style for all formulas.

**Current files:**
- `shaders/escape_time_perturb_gpu.frag`

**Patch idea:**
- Add formula-dependent `log2Power`:
  - 0..5,9 -> `1.0`
  - 6 -> `log2(3.0)`
  - 7 -> `2.0`
  - 8 -> `log2(5.0)`
- Apply `smoothVal = f(it, finalMag2) / log2Power` style to match dedicated multibrot shaders.

**Expected impact:** better color continuity and reduced band mismatch on perturb-enabled multibrot formulas.

**Risk:** low.

---

## P1 — Skip derivative updates unless normal-map schemes are active (low risk, perf)

**Why:** In common palettes (schemes 0–49), derivative recurrence is unnecessary overhead.

**Current files (start with hot set):**
- `shaders/mandel_step_smooth.frag`
- `shaders/julia_gpu.frag`
- `shaders/burning_ship_gpu.frag`
- `shaders/multibrot3_gpu.frag`

**Patch idea:**
- Compute `bool needNormal = (schemeInt >= 50);`
- In loop, update `der` only when `needNormal`.
- Keep exact current behavior for schemes 50–63.

**Expected impact:** measurable frame-time reduction in default palettes.

**Risk:** low.

---

## P1 — Propagate Mandelbrot cardioid/bulb early-out to DF2 and DE shaders (low risk, perf)

**Why:** Already proven in `mandel_step_smooth.frag`; not yet in other heavy Mandelbrot variants.

**Current files:**
- `shaders/mandelbrot_df2.frag`
- `shaders/mandelbrot_de_gpu.frag`

**Patch idea:**
- Add `inMainBulb(vec2 c)` helper and skip full loop for guaranteed interior points.
- Preserve existing transparency/inside rendering semantics.

**Expected impact:** significant speedup on overview views and interior-heavy regions.

**Risk:** low.

---

## P2 — Adaptive perturb orbit encoding scale (precision robustness)

**Why:** Current orbit cache clamps each component to `[-4,4)`, which can clip reference orbits and reduce perturbation stability.

**Current files:**
- `lib/core/modules/escape_time_perturb_module.dart`
- `lib/core/modules/julia_perturb_module.dart`
- `shaders/escape_time_perturb_gpu.frag`

**Patch idea:**
- During orbit build, compute `orbitScale = max(abs(zr), abs(zi), epsilon)` across reference orbit.
- Encode normalized values (`value / orbitScale`) to RG pairs.
- Send `orbitScale` via `uExtra2` (already wired but unused).
- Decode as `decoded * orbitScale` in shader.

**Expected impact:** fewer clipping-induced artifacts and better deep-zoom robustness.

**Risk:** low-medium (touches encode/decode contract).

---

## P2 — Add tiny deterministic palette-phase dithering to reduce banding (low risk)

**Why:** kf2 demonstrates practical dither in color mapping; this helps at low-contrast gradients and static views.

**Current files (initial):**
- `shaders/mandel_step_smooth.frag`
- `shaders/julia_gpu.frag`
- `shaders/burning_ship_gpu.frag`
- `shaders/mandelbrot_df2.frag`

**Patch idea:**
- Add a minimal hash from `fragCoord` and perturb `t` by ~`1/1024` before palette lookup.
- Keep amplitude small and deterministic (no temporal shimmer).

**Expected impact:** reduced visible color banding with negligible cost.

**Risk:** low.

---

## P3 — Fix bailout semantic overload in Stripe Average shader (small UX/consistency cleanup)

**Why:** `mandelbrot_stripe_avg_gpu.frag` repurposes `uBailout` as stripe frequency, while UI label remains bailout.

**Current files:**
- `shaders/mandelbrot_stripe_avg_gpu.frag`
- `lib/core/modules/builders/escape_time_catalog.dart` (module `mandelbrot_stripe_avg`)

**Patch idea:**
- Introduce extra param (e.g., `stripeFrequency`) via `extraParams`.
- Keep bailout meaning consistent app-wide.
- Map old presets by translating `bailout` -> `stripeFrequency` once.

**Expected impact:** clearer controls, fewer user-side mis-tuning errors.

**Risk:** low-medium (preset migration touchpoint).

---

## Suggested execution order

1. **P1 iteration cap alignment**
2. **P1 perturb power-aware smoothing**
3. **P1 derivative lazy updates (hot shaders first)**
4. **P1 cardioid/bulb in DF2 + DE**
5. **P2 adaptive perturb orbit scale**
6. **P2 palette dithering**
7. **P3 stripe-frequency param cleanup**

---

## Minimal validation plan per patch

- Visual A/B snapshots on: Mandelbrot default, Seahorse preset, Julia default, Burning Ship default, perturb-enabled multibrot3.
- FPS/frame-time sampling in debug overlay before/after.
- Zoom transition checks near precision boundaries (`~5e6`, `~1e14`, `~1e30`).
- Shader compile smoke test on Linux + Android emulator (no new uniforms left unset).

---

## Note on breadth

Recommendations are intentionally constrained to **surgical shader/runtime changes** and avoid broad architecture refactors.
