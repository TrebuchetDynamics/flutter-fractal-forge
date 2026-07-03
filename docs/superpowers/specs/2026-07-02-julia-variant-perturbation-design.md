# Julia-Variant Perturbation (Deep Zoom) — Design

**Date:** 2026-07-02
**Status:** Approved design, pending implementation plan
**Builds on:** commit `fd72b705` (Julia orbit 24-bit encoding fix, reference-orbit
period detection, batched orbit-texture rasterization)

## Problem

1. **Live bug — core Julia perturbation renders flat.** In
   `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`, `dz` is
   initialized to `vec2(0.0)` for every formula, and `deltaJulia(Zn, dz)` has
   no `dc` source term. For `uFormula == 1` (Julia), `dz` therefore stays
   identically zero: `fullZ = Zn + 0` for every pixel, so the whole frame
   renders one flat color whenever the Julia perturbation module is active.
   Additionally, `computeJuliaPerturbOrbitBytes` stores Z₁ in pixel 0
   (encode-after-iterate), while the shader's `fetchOrbit(n)` must align with
   `dz_n`, which requires Z₀ in pixel 0 (the escape-time module's convention).
2. **Coverage gap (TODO P1-1b).** ~30+ catalog Julia variants (celtic_julia,
   buffalo_julia, burning_ship_julia, tricorn_julia, multibrot3–5_julia,
   phoenix_julia, plus 16 preset-c julias `f0143`–`f0158`) have no deep-zoom
   perturbation path and degrade at high zoom.

## Key insight (approach C — chosen)

A Julia variant of any base formula uses the *identical* delta iteration as
its Mandelbrot form with the `dc` term zeroed (c is constant), and the pixel
offset entering through the initial delta instead:

- **Mandelbrot form:** `dz₀ = 0`, `dc = pixel offset`, orbit seeded `z₀ = 0`,
  `c = center`.
- **Julia form:** `dz₀ = pixel offset`, `dc = 0`, orbit seeded `z₀ = center`,
  `c = (juliaCReal, juliaCImag)` fixed.

The shader already contains delta functions for all 9 base formulas
(`deltaMandelbrot`, `deltaBurningShip`, `deltaBuffalo`, `deltaTricorn`,
`deltaCeltic`, `deltaMultibrot3/4/5`, phoenix else-branch). A single
julia-mode flag therefore gives every base formula its Julia variant with
**zero new delta functions**, and fixes the core Julia bug by construction
(`deltaJulia` becomes redundant with `deltaMandelbrot` under `dc = 0`).

Rejected alternatives: per-variant formula branches (30× copy-paste across
Dart + shader; the same private-copy drift that caused the Julia 16-bit
encoding bug), and a universal data-driven formula description (rewrite of a
working shader; speculative generality).

## Design

### Shader (`escape_time_perturb_gpu.frag`)

- `uExtra2` (currently always 0.0) becomes the julia-mode flag.
- In `main()`:
  - `bool juliaMode = uExtra2 > 0.5;`
  - `vec2 dz = juliaMode ? dc : vec2(0.0);`
  - `vec2 dcEff = juliaMode ? vec2(0.0) : dc;` — passed to all delta calls.
- `formula == 1` routes through `deltaMandelbrot(Zn, dz, dcEff)`;
  `deltaJulia` is removed (it is that expression with `dc` dropped).
- Backward compatibility: non-julia modules pass `uExtra2 = 0.0` (already the
  case), so their behavior is bit-identical.

### Orbit computation (`escape_time_perturb_module.dart`)

- `computeEscapeTimePerturbOrbitBytes` gains an optional julia seed:
  `juliaSeed: (cReal, cImag)?`. When present: `z₀ = (centerX, centerY)`,
  iteration constant `c = juliaSeed`. Encoding stays store-Z₀-first, so the
  shader's `fetchOrbit(n) ↔ dz_n` alignment holds for both modes.
- Period detection, escape break, and 24-bit packing apply unchanged.
- `computeJuliaPerturbOrbitBytes` in `julia_perturb_module.dart` is deleted;
  the julia module calls the unified function (removing the store-Z₁-first
  off-by-one and the last remaining duplicate orbit code path).

### Routing

- Variant table in `escape_time_perturb_module.dart`:
  `variantId → (baseFormulaInt, juliaMode)`. Initial coverage — variants whose
  base delta exists in the shader AND whose module exposes fixed-c params:
  - `celtic_julia`, `buffalo_julia`, `burning_ship_julia`, `tricorn_julia`
  - `multibrot3_julia`, `multibrot4_julia`, `multibrot5_julia`
  - `phoenix_julia`
  - core `julia` (bug-fix path, now via the unified module)
  - `f0143`–`f0158` preset-c julias (z² + preset c) — included only if their
    modules expose `juliaCReal`/`juliaCImag` (verify during implementation).
- `RendererPlanModuleResolver` routes these IDs to the perturbation wrapper at
  deep zoom, mirroring the existing 8 escape-time IDs + `julia`.
- **Explicitly excluded (no shader delta; CPU/standard path continues):**
  cubic/power4–7 variants of burning_ship/celtic/buffalo, trig julias
  (`cosine_julia`, `cosh_julia`, `exponential_julia`, `cosecant_julia`,
  `cotangent_julia`), `dual_quaternion_julia`, `complex_henon_julia_slice`,
  `burning_ship_perp_julia`. No speculative delta authoring in this slice.

### Error handling

- Unknown/excluded IDs never enter the variant table, so behavior for them is
  unchanged.
- The existing renderer health/precision policy (GPU→CPU fallback) remains the
  safety net for any variant that misbehaves at depth.

### Testing

1. **Dart mirror of the shader delta iteration** (new test): implement the
   delta recurrence in Dart exactly as the shader computes it (per formula,
   both modes), iterate against the real orbit bytes (decoded with
   `decodePerturbOrbitComponent`), and compare `Zn + dz_n` against direct
   double-precision iteration of the pixel point. Locks the
   orbit-convention + dz-init + dc-zeroing contract numerically without a
   GPU. Must FAIL against today's julia behavior (dz ≡ 0) — regression proof.
2. **Per-variant orbit tests**: julia-seeded orbit bytes vs direct iteration
   (pattern from `test/julia_perturb_orbit_encoding_test.dart`).
3. **Routing tests**: variant IDs resolve to the perturbation wrapper at deep
   zoom (`renderer_plan_policy_test` pattern).
4. **Flat-render regression (integration, `-d linux` + xvfb)**: render the
   julia perturbation module at zoom ≥ 1e8 and assert non-uniform pixel
   output (variance > 0) — the end-to-end gate on the shipped bug.
5. Existing suites must stay green: orbit encoding/period/texture tests,
   shader compile diagnostics, catalog integrity (no module count change —
   only deep-zoom routing of existing IDs).

### Success criteria (from TODO P1)

- Julia (and each routed variant) zoomed to 1e10 renders smooth, spatially
  varying detail (no flat frame, no banding).
- No behavior change for non-julia perturbation IDs (bit-identical shader
  path when `uExtra2 = 0`).

## Out of scope

- Series approximation (TODO P1-2) — next sub-project, separate spec.
- New delta functions for cubic/power/trig variants.
- Smooth-coloring rollout to non-perturbation shaders (P1-3).
