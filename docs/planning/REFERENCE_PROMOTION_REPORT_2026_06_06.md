# Reference Promotion Report — 2026-06-06

**Purpose:** Identify the fastest honest path from “large catalog” to “larger, cooler, validated catalog.”
**Scope:** App/registry drift and reference-tier promotion candidates.
**Companion backlog:** `docs/planning/WORLD_FRACTAL_CATALOG_EXPANSION_BACKLOG.md`.
**Full candidate CSV:** `docs/planning/APP_REGISTRY_SYNC_CANDIDATES_2026_06_06.csv`.

## Approved sync slice applied

After owner approval on 2026-06-06, the first registry-sync slice was applied:

- Added 7 implemented registry entries: `domain_coloring`, `phase_portrait`, `gray_scott_rd`, `lichtenberg_growth`, `hofstadter_butterfly`, `magnetic_pendulum`, `shape_modulus_julia`.
- Promoted/reconciled 3 existing reference entries to implemented tier with app shader paths and app-id aliases:
  - `f0290_kleinian_limit_set` ← `kleinian_limit_set`
  - `f1142_buddhabrot` ← `buddhabrot_full`
  - `f0011_m_ller_s_method` ← `muller`
- Updated `APP_REGISTRY_SYNC_CANDIDATES_2026_06_06.csv` with `sync_status` and `registry_resolution` columns.
- Current remaining CSV status: 92 pending app configs plus 3 reconciled aliases retained for traceability.
- Validation: `PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --strict-app-catalog` → `forge doctor: OK (1595 entries, 0 error(s), 0 warning(s))`.
- Subsequent frontier reference micro-batches added 15 reference-tier-only entries; current strict doctor receipt is tracked in `FRONTIER_REFERENCE_PROMOTION_REPORT_2026_06_06.md` at 1,610 entries.
- Focused registry sync check: OK — the 10 approved app IDs are represented in the registry, marked implemented, and point to shader files that exist.
- Focused shader asset tests: OK — root-finding, cellular/stochastic, IFS/geometric, and trigonometric/transcendental shader asset tests all passed.
- Count-snapshot cleanup: `test/catalog_id_integrity_test.dart` now reflects the live catalog/module counts after the internal `escape_time_perturb` shader was removed from the user-visible escape-time catalog. Combined focused validation passes.

## Initial evidence before approved sync slice

| Check | Result |
|---|---:|
| `docs/catalog/fractal_registry.yaml` entries | 1,588 |
| Registry implemented tier | 357 |
| Registry reference tier | 1,231 |
| App escape-time configs parsed from `lib/core/modules/builders/escape_time_catalog.dart` | 452 unique IDs |
| App escape-time configs missing from registry | 102 IDs |
| Missing-from-registry app configs whose shader files exist | 102 / 102 |
| Missing-from-registry app configs whose shaders are in `pubspec.yaml` | 102 / 102 |
| Reference-tier registry entries with planned shader paths but no shader file | 1,231 / 1,231 |

Key finding: the quickest near-term gain is **registry synchronization for already app-registered shaders**, not writing new shaders. Initially, there were 102 app-visible or app-registerable modules that had shader files and pubspec declarations but were absent from the research registry. The refreshed CSV now tracks remaining pending candidates plus reconciled aliases.

## Interpretation

There are two different expansion tracks:

1. **Registry sync track:** app already has shader + module config + pubspec declaration, but `docs/catalog/fractal_registry.yaml` lacks the entry. This improves catalog truth and research count without changing renderer code.
2. **Promotion track:** registry has a reference entry, but no actual shader file exists at the planned path. These need implementation, thumbnail proof, and tests before app visibility.

Do **not** count debug shaders, precision variants, or duplicated presets as new mathematical fractal types unless the registry explicitly treats them as renderer variants with aliases.

## Tier 0 — Best immediate registry-sync candidates

These are already app-configured with existing shader files and pubspec declarations. They should be admitted or reconciled into the registry before new shader work.

| Rank | App ID | Current app category | Shader | Why it is valuable |
|---:|---|---|---|---|
| 1 | `domain_coloring` | Escape-Time | `shaders/escape_time_family/orbit_and_domain/domain_coloring_gpu.frag` | Unlocks a whole complex-function visualization category. |
| 2 | `phase_portrait` | Escape-Time | `shaders/escape_time_family/orbit_and_domain/phase_portrait_gpu.frag` | Strong educational/math-art module; easy single-pass validation. |
| 3 | `kleinian_limit_set` | Escape-Time | `shaders/ifs_and_geometric/kleinian_limit_set_gpu.frag` | High visual distinctiveness; bridges IFS/Kleinian roadmap. |
| 4 | `buddhabrot_full` | Escape-Time | `shaders/escape_time_family/families/buddhabrot/buddhabrot_full_gpu.frag` | Major fractal-art family; should be tracked separately from approximations. |
| 5 | `gray_scott_rd` | Escape-Time | `shaders/cellular_and_stochastic/gray_scott_rd_gpu.frag` | Reaction-diffusion showcase; validate whether it is approximation vs stateful simulation. |
| 6 | `lichtenberg_growth` | Cellular & Stochastic Growth | `shaders/cellular_and_stochastic/lichtenberg_growth_gpu.frag` | Lightning/electric-discharge aesthetic; high “cool” value. |
| 7 | `hofstadter_butterfly` | Escape-Time | `shaders/escape_time_family/geometry_and_ifs/hofstadter_butterfly_gpu.frag` | Number-theory/physics crossover; differentiates catalog. |
| 8 | `magnetic_pendulum` | Escape-Time | `shaders/escape_time_family/experimental_named/physical_simulation/magnetic_pendulum_gpu.frag` | Basin/fractal physics visual with clear user story. |
| 9 | `shape_modulus_julia` | Escape-Time | `shaders/escape_time_family/julia_variants/shape_modulus_julia_gpu.frag` | Signature “shape-driven Julia” direction. |
| 10 | `sierpinski_julia_rational` | Escape-Time | `shaders/ifs_and_geometric/sierpinski_julia_rational_gpu.frag` | Bridges rational dynamics and classical fractals. |
| 11 | `alternated_iteration` | Escape-Time | `shaders/escape_time_family/experimental_named/coupled_orbits/alternated_iteration_gpu.frag` | Adds map-switching dynamics, not just another power variant. |
| 12 | `weierstrass_elliptic` | Escape-Time | `shaders/trigonometric_and_transcendental/special_functions/weierstrass_elliptic_gpu.frag` | Rare special-function visual; encyclopedia value. |
| 13 | `weierstrass_function` | Escape-Time | `shaders/trigonometric_and_transcendental/special_functions/weierstrass_function_gpu.frag` | Classic nowhere-differentiable function; educational value. |
| 14 | `dirichlet_eta` | Escape-Time | `shaders/trigonometric_and_transcendental/special_functions/dirichlet_eta_gpu.frag` | Special-function/domain-coloring frontier. |
| 15 | `mittag_leffler` | Escape-Time | `shaders/trigonometric_and_transcendental/special_functions/mittag_leffler_gpu.frag` | Rare complex special-function fractal. |
| 16 | `jacobi_sn` | Escape-Time | `shaders/trigonometric_and_transcendental/special_functions/jacobi_sn_gpu.frag` | Elliptic-function family; visually distinct. |
| 17 | `muller` | Escape-Time | `shaders/root_finding/muller_gpu.frag` | Root-finding gap with existing shader. |
| 18 | `jarratt` | Escape-Time | `shaders/root_finding/jarratt_gpu.frag` | Root-finding method expansion; reusable validation. |
| 19 | `ostrowski` | Escape-Time | `shaders/root_finding/ostrowski_gpu.frag` | Root-finding method expansion. |
| 20 | `neta_order16` | Escape-Time | `shaders/root_finding/neta_order16_gpu.frag` | High-order root-finding basin visual. |
| 21 | `noor_newton` | Escape-Time | `shaders/root_finding/noor_newton_gpu.frag` | Newton-family variant with distinct iteration. |
| 22 | `picard_mann_newton` | Escape-Time | `shaders/root_finding/picard_mann_newton_gpu.frag` | Iterative-method variant; good math story. |
| 23 | `super_halley` | Escape-Time | `shaders/root_finding/super_halley_gpu.frag` | Natural companion to existing Halley modules. |
| 24 | `traub_ostrowski` | Escape-Time | `shaders/root_finding/traub_ostrowski_gpu.frag` | High-order method; root-finding expansion. |
| 25 | `steffensen` | Escape-Time | `shaders/root_finding/steffensen_gpu.frag` | Derivative-free method; good contrast to Newton-family basins. |

### Tier 0 caveats

- `muller` likely corresponds to reference entry `f0011_m_ller_s_method`; reconcile aliases rather than creating duplicate canonical entries.
- `kleinian_limit_set` likely overlaps reference entry `f0290_kleinian_limit_set`; reconcile IDs/aliases.
- `gray_scott_rd` overlaps the Gray-Scott reference pack (`f0724`–`f0738`); classify whether the app shader is a general renderer or one preset.
- Legacy Mandelbrot renderer variants (`mandelbrot_df2`, `mandelbrot_simple`, `mandelbrot_tex`, etc.) should be renderer variants, not separate fractal types.
- The kaleidoscope pack has 15 registered shaders; decide whether these are a catalog category or visual effects before counting them as fractal entries.

## Tier 1 — Registry reference entries that need implementation

These are valuable, but their planned shader files do not exist yet.

| Rank | Registry ID | Name | Category | Recommended path |
|---:|---|---|---|---|
| 1 | `f0013_polynomiography_basic_family_iteration` | Polynomiography (Basic Family Iteration) | Newton / Root-Finding | Implement after `muller`/root sync; use root-basin shader template. |
| 2 | `f0001_mitchell_adjusted_newton` | Mitchell Adjusted Newton | Newton / Root-Finding | High visual payoff; Bridges citation; single-pass basin shader. |
| 3 | `f0002_mitchell_rotating_c_newton` | Mitchell Rotating-C Newton | Newton / Root-Finding | Animated/parameterized Newton variant; single-pass with time/constant controls. |
| 4 | `f0003_mitchell_alternating_equations_newton` | Mitchell Alternating-Equations Newton | Newton / Root-Finding | Map-switching basins; single-pass loop. |
| 5 | `f0291_schottky_circle_ifs` | Schottky Circle IFS | IFS & Geometric Construction | Prototype as circle-inversion renderer; strong Kleinian roadmap link. |
| 6 | `f0289_apollonian_packing_ifs` | Apollonian Packing IFS | IFS & Geometric Construction | Reconcile with `apollonian_gasket`; implement distinct packing renderer only if unique. |
| 7 | `f0770_continued_fraction_fractal` | Continued Fraction Fractal | Number-Theory Fractals | Good single-pass/procedural candidate; rare category. |
| 8 | `f0759_ford_circles_apollonian` | Ford Circles Apollonian | Number-Theory Fractals | Reconcile with `ford_circles`; add only if Apollonian hybrid is distinct. |
| 9 | `f0602_kleinian_3d_indra` | Kleinian 3D Indra | 3D Raymarching & Hypercomplex | Raymarch prototype; require frame-budget proof. |
| 10 | `f0603_kleinian_schottky_3d` | Kleinian Schottky 3D | 3D Raymarching & Hypercomplex | Raymarch prototype; require frame-budget proof. |
| 11 | `f1104_fractal_flame_v3_swirl` | Fractal Flame V3 Swirl | IFS & Geometric Construction | Reference-tier OK; implemented tier needs accumulation/progressive proof. |
| 12 | `f1105_fractal_flame_v4_horseshoe` | Fractal Flame V4 Horseshoe | IFS & Geometric Construction | Same flame renderer as `f1104`; do not hand-build one shader per variation. |
| 13 | `f0724_gray_scott_spots` | Gray-Scott Spots | Reaction-Diffusion & Chemical | Use only after deciding stateful vs approximation strategy. |
| 14 | `f0749_brusselator` | Brusselator | Reaction-Diffusion & Chemical | Prototype multi-pass/ping-pong before app admission. |
| 15 | `f0331_lenia_orbium` | Lenia (orbium) | Cellular & Stochastic | High cool factor but stateful; prototype first. |

## Recommended next implementation slice

**Do not write a new shader first.** Start with a registry sync slice:

1. Choose 10 Tier-0 entries that are true fractal/math entries, not renderer variants.
2. Add them to `docs/catalog/fractal_registry.yaml` or reconcile them with existing reference IDs.
3. Include aliases pointing between app IDs and `fNNNN_...` reference IDs where overlap exists.
4. Run `PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --strict-app-catalog`.
5. Run a focused app/catalog test if available for module-registry visibility.

Recommended first 10:

1. `domain_coloring`
2. `phase_portrait`
3. `kleinian_limit_set` / reconcile with `f0290_kleinian_limit_set`
4. `buddhabrot_full`
5. `gray_scott_rd` / reconcile with Gray-Scott pack
6. `lichtenberg_growth`
7. `hofstadter_butterfly`
8. `magnetic_pendulum`
9. `shape_modulus_julia`
10. `muller` / reconcile with `f0011_m_ller_s_method`

## Validation command used for this report

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --strict-app-catalog
# forge doctor: OK (1588 entries, 0 error(s), 0 warning(s))
```
