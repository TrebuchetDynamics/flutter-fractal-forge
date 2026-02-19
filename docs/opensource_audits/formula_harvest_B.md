# Formula Harvest B (kf2 + FractalShark + giulia + JWildfire + Fractl)

Date: 2026-02-18

## Scope

Requested sources scanned under `/home/xel/git/flutter-fractal-forge/opensource`:

- `kf2`
- `FractalShark`
- `giulia`
- `JWildfire`
- `Fractl`

Compared against current app coverage in:

- `lib/core/modules/builders/escape_time_catalog.dart`
- `lib/core/modules/module_registry.dart`

Baseline compared IDs (normalized): **454**.

## Harvest summary

- Concrete missing formulas/variants identified: **42**
- Source mix:
  - **kf2:** 30
  - **JWildfire:** 6
  - **FractalShark:** 3 (deep-zoom Mandelbrot variants)
  - **giulia:** 1
  - **Fractl:** 2
- Portability priority focus: formulas that fit Flutter fragment/compute style first; deep-zoom algorithm variants second.

---

## Candidate list (missing from current app)

> Portability legend: **High** = straightforward fragment/CPU port, **Med** = moderate loops/branches or 3D math, **Low-Med** = deep-zoom/high-precision engineering.

### A) kf2-derived advanced escape-time variants

1. `redshift_rider_1` — kf2 type 42 (`A*z^2 + z^3 + c`) — **High**
2. `redshift_rider_2` — kf2 type 43 (`A*z^2 - z^3 + c`) — **High**
3. `redshift_rider_3` — kf2 type 44 (`2*z^2 - z^3 + c`) — **High**
4. `redshift_rider_4` — kf2 type 45 (`A*z^2 + z^4 + c`) — **High**
5. `redshift_rider_5` — kf2 type 46 (`A*z^2 - z^4 + c`) — **High**
6. `redshift_rider_6` — kf2 type 47 (`A*z^2 + z^5 + c`) — **High**
7. `redshift_rider_7` — kf2 type 48 (`A*z^2 - z^5 + c`) — **High**
8. `redshift_rider_8` — kf2 type 49 (`A*z^2 + z^6 + c`) — **High**
9. `redshift_rider_9` — kf2 type 50 (`A*z^2 - z^6 + c`) — **High**
10. `simonbrot2_4th` — kf2 type 51 (Simonbrot family extension) — **High**
11. `mothbrot_2nd_1x1` — kf2 type 54 (abs-weighted hybrid power-2) — **Med**
12. `mothbrot_3rd_1x2` — kf2 type 55 — **Med**
13. `mothbrot_3rd_2x1` — kf2 type 56 — **Med**
14. `mothbrot_4th_1x3` — kf2 type 57 — **Med**
15. `mothbrot_5th_1x4` — kf2 type 60 — **Med**
16. `mothbrot_6th_1x5` — kf2 type 64 — **Med**
17. `omnibrot` — kf2 type 71 (`z^2 * exp(2A/z) + c`) — **Med**
18. `polarbrot` — kf2 type 74 (polar/log-exp transformed power map) — **Med**
19. `cosbrot` — kf2 type 93 (`cos(z) + c`) — **High**
20. `sinbrot` — kf2 type 94 (`sin(z) + c`) — **High**
21. `separated_perpendicular` — kf2 type 91 (diffabs-separated perpendicular map) — **High**
22. `hpdz_buffalo` — kf2 type 41 (Buffalo-derived) — **High**
23. `cubic_flying_squirrel` — kf2 type 13 (Buffalo-imag cubic) — **High**
24. `cubic_partial_bs_real` — kf2 type 11 — **High**
25. `cubic_partial_bs_imag` — kf2 type 12 — **High**
26. `quintic_quasi_perpendicular_burning_ship` — kf2 type 87 — **Med**
27. `simon_0139c_plain` — kf2 type 80 — **Med**
28. `simon_0139c_burning_ship` — kf2 type 81 — **Med**
29. `simon_0139c_celtic` — kf2 type 82 — **Med**
30. `simon_0139c_buffalo` — kf2 type 83 — **Med**

### B) JWildfire-derived formula/variant candidates

31. `kali_set2` — from `DC_KaliSet2Func` / `GLSLKaliSet2Func` (circle inversion + affine cycle) — **High**
32. `mandelbox_2d_de` — from `DC_MandelBox2DFunc` / `GLSLMandelBox2DFunc` (2D boxfold+ballfold DE-style) — **Med**
33. `apollonian_fold_3d` — from `DC_ApollonianFunc` / `GLSLApollonianFunc` (iterated fold/inversion Apollonian style) — **Med**
34. `phoenix_julia_variation` — from `PhoenixJuliaFunc` (Phoenix-style Julia branching) — **High**
35. `julia3dq` — from `Julia3DQFunc` (3D quaternion Julia map variant) — **Med**
36. `julia3dz` — from `Julia3DZFunc` (3D Julia-z transform variant) — **Med**

### C) FractalShark-derived advanced Mandelbrot variants (engine/formula pipeline)

37. `mandelbrot_la_bla_pipeline` — LA/BLA accelerated perturbation stack variant — **Low-Med**
38. `mandelbrot_gpu_reference_orbit` — GPU-built high-precision reference orbit variant — **Low-Med**
39. `mandelbrot_reference_compression` — compressed-orbit runtime decompression variant — **Low-Med**

### D) giulia-derived candidate

40. `mandelbrot_julia_variable_exponent` — unified `z^n + c` with runtime exponent (single kernel for Mandelbrot/Julia) — **High**

### E) Fractl-derived candidates

41. `multibrot_real_exponent` — real-valued exponent multibrot (not just fixed integer presets) — **High**
42. `mandelbrot_cardioid_period2_culling` — analytic interior rejection variant (fast-path before iteration) — **High**

---

## Top-10 high-ROI shortlist

These are the strongest near-term wins for Flutter GPU/CPU portability + user-visible differentiation.

| Rank | Candidate | Why high ROI | Portability | Suggested wave |
|---|---|---|---|---|
| 1 | `redshift_rider_1..9` (as one parametric family) | 9 formulas from one implementation pattern (`a*z^2 ± z^p + c`) | High | Wave 1 |
| 2 | `cosbrot` | Trig map gives immediately new morphology with low engineering risk | High | Wave 1 |
| 3 | `sinbrot` | Companion to cosbrot; shared complex trig code path | High | Wave 1 |
| 4 | `omnibrot` | Distinct transcendental look; advanced but still 2D escape-time | Med | Wave 1-2 |
| 5 | `polarbrot` | Polar/log-exp transformed variant, visually distinct from existing multibrots | Med | Wave 1-2 |
| 6 | `kali_set2` | Strong visual novelty; compact shader math, easy CPU fallback | High | Wave 1 |
| 7 | `phoenix_julia_variation` | Extends existing Phoenix family with low implementation cost | High | Wave 1 |
| 8 | `multibrot_real_exponent` | Upgrades static multibrot catalog to continuous exponent control | High | Wave 1 |
| 9 | `mandelbrot_cardioid_period2_culling` | Big perf win for both GPU/CPU without changing UX complexity | High | Wave 0 (engine) |
| 10 | `julia3dq` | High visual differentiation; manageable next step toward richer 3D Julia | Med | Wave 2 |

---

## Practical implementation notes

1. **Exploit family generators**
   - Implement Redshift Rider as parameterized template (`sign`, `power`, `coeff`) and materialize 9 presets.
   - Implement Mothbrot as coefficient table presets to avoid per-variant shader duplication.

2. **CPU fallback strategy**
   - For trig/exponential variants (cosbrot/sinbrot/omnibrot/polarbrot), add shared complex transcendental helpers once.
   - Reuse smooth-escape coloring path and existing bailout controls.

3. **Deep-zoom variants from FractalShark**
   - Treat as **engine roadmap** items, not first-wave formula adds.
   - Start with `cardioid_period2_culling` and precision-path cleanup before LA/BLA/reference compression.

4. **Licensing safety**
   - `kf2` is AGPL-3.0; `FractalShark` GPL-3.0; `Fractl` GPL-3.0; `JWildfire` LGPL-2.1+; `giulia` license not clearly declared at repo root.
   - For copyleft/unclear cases: implement clean-room from mathematical definitions, avoid copy/paste of source code.

---

## Evidence pointers (where formulas/variants were harvested)

- kf2 formulas: `opensource/kf2/formula/formula_*.xml`
- kf2 preset corpus: `opensource/kf2/formulas/*.kfr`
- FractalShark variant capabilities: `opensource/FractalShark/README.md`
- giulia exponent-based shader path: `opensource/giulia/src/gl/shaders/single_precision.shader`
- JWildfire variants: `opensource/JWildfire/src/org/jwildfire/create/tina/variation/*`
- JWildfire GLSL refs: `opensource/JWildfire/glsl/*.txt`
- Fractl compute shader and optimizations: `opensource/Fractl/fractl_lib/src/shader.wgsl`

---

## Recommendation

Ship **Wave 1** as a high-impact, low-risk package:

- `redshift_rider` family (9 presets)
- `cosbrot`
- `sinbrot`
- `phoenix_julia_variation`
- `multibrot_real_exponent`
- `mandelbrot_cardioid_period2_culling`

This bundle gives strong novelty + performance gains while staying highly portable to current Flutter GPU/CPU architecture.