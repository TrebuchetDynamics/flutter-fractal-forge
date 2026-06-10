# Frontier Reference Promotion Report — 2026-06-06

**Purpose:** Turn the 105-row frontier research matrix into the first 25 registry-safe reference-promotion targets without inflating implemented app catalog counts.

**Inputs:**

- `docs/planning/FRACTAL_FRONTIER_CANDIDATES_2026_06_06.csv` — 105 frontier candidate families.
- `docs/catalog/fractal_registry.yaml` — live registry now checked at 1,610 entries / 367 implemented / 1,243 reference.
- Targeted registry searches for likely alias collisions including Lattès, Schottky, Rauzy, p-adic, DLA, and Gaussian integer terms.

**Machine-readable output:** `docs/planning/FRONTIER_REFERENCE_PROMOTION_TOP25_2026_06_06.csv`.

## Applied micro-batches

### `frontier_reference_microbatch_2026_06_06`

- `exponential_family_parameter_plane` — Exponential Family Parameter Plane
- `sine_family_parameter_plane` — Sine Family Parameter Plane
- `dedekind_eta_function_coloring` — Dedekind Eta Function Coloring
- `schwarz_triangle_function_tessellation` — Schwarz Triangle Function Tessellation
- `gamma_function_newton_fractal` — Gamma Function Newton Fractal

### `frontier_reference_microbatch_2_2026_06_06`

- `baker_domain_exponential_map` — Baker Domain Exponential Map
- `modular_lambda_function_coloring` — Modular Lambda Function Coloring
- `newton_basins_for_trigonometric_equations` — Newton Basins for Trigonometric Equations
- `householder_order_four_basin` — Householder Order Four Basin
- `coxeter_honeycomb_435_slice` — Coxeter Honeycomb 435 Slice

### `frontier_reference_microbatch_3_2026_06_06`

- `hyperbolic_honeycomb_534_slice` — Hyperbolic Honeycomb 534 Slice
- `dodecahedral_fold_fractal` — Dodecahedral Fold Fractal
- `4d_polychoron_fold_slice` — 4D Polychoron Fold Slice
- `paperfolding_curve_atlas` — Paperfolding Curve Atlas
- `modular_tessellation_fundamental_domain` — Modular Tessellation Fundamental Domain

All promoted entries were added with `tier: reference`, `implemented: false`, `shader_compile: n/a`, source URLs checked from the agent environment, and no app-visible implementation claims. Registry doctor after the latest micro-batch reports `forge doctor: OK (1610 entries, 0 error(s), 0 warning(s))`.

Validation receipts:

```text
source url check: OK urls=23
frontier promotion consistency: OK registry=1610 promoted=15 top25=25
/home/xel/flutter/bin/flutter test test/catalog_id_integrity_test.dart
All tests passed
```

## Ranking method

Scored candidates for:

1. **Catalog distinctiveness:** adds a family users will recognize as meaningfully different, not just a parameter preset.
2. **Reference safety:** exact/fuzzy/targeted registry scans classify whether to add, reconcile, or hold.
3. **Implementation path clarity:** single-pass shader candidates rank higher than stateful/progressive candidates for near-term app work.
4. **World-catalog cool factor:** visually or mathematically rare categories such as transcendental dynamics, modular/domain coloring, hyperbolic/Kleinian systems, p-adic dynamics, and living/stateful systems.
5. **Honesty gates:** every candidate keeps an app-admission gate and remains reference-only until formula/provenance and rendering proof exist.

## Summary

| Signal | Count |
|---|---:|
| Ranked candidates | 25 |
| Promoted to reference tier from Top 25 | 15 |
| Still candidates / not registry-added from Top 25 | 10 |
| Implemented-tier changes made | 0 |

Promotion-action mix after micro-batches:

| Action | Count |
|---|---:|
| `new_3d_reference_or_variant` | 1 |
| `new_reference_research_only` | 1 |
| `new_reference_stateful` | 1 |
| `new_reference_with_gaussian_lattice_dedup` | 1 |
| `new_reference_with_p_adic_dedup` | 1 |
| `promoted_reference` | 15 |
| `reconcile_existing_reference` | 3 |
| `reconcile_or_new_stateful_variant` | 1 |
| `reconcile_or_reference_family` | 1 |

Animation-class mix:

| Class | Count |
|---|---:|
| `camera_path` | 6 |
| `growth_process` | 2 |
| `parameter_morph` | 13 |
| `phase_rotation` | 2 |
| `stateful_grid` | 1 |
| `time_parametric` | 1 |

Renderer-class mix:

| Class | Count |
|---|---:|
| `procedural_geometry` | 2 |
| `procedural_geometry_or_reference` | 1 |
| `raymarched_or_escape_limit_set` | 1 |
| `raymarched_sdf` | 4 |
| `raymarched_slice` | 1 |
| `reference_first` | 2 |
| `single_pass_domain_coloring` | 3 |
| `single_pass_escape_time` | 4 |
| `single_pass_geometry` | 1 |
| `single_pass_or_raymarch` | 1 |
| `single_pass_root_finding` | 3 |
| `stateful_grid_or_particles` | 1 |
| `stateful_particles_or_grid` | 1 |

## Top 25 reference-promotion targets

| Rank | Candidate | Name | Renderer | Animation | Registry-safe action | Status | Dedup signal |
|---:|---|---|---|---|---|---|---|
| 1 | `exponential_family_parameter_plane` | Exponential Family Parameter Plane | single_pass_escape_time | parameter_morph | promoted_reference | promoted_reference | none found in fuzzy scan |
| 2 | `sine_family_parameter_plane` | Sine Family Parameter Plane | single_pass_escape_time | parameter_morph | promoted_reference | promoted_reference | none found in fuzzy scan |
| 3 | `baker_domain_exponential_map` | Baker Domain Exponential Map | single_pass_escape_time | time_parametric | promoted_reference | promoted_reference | none found in fuzzy scan |
| 4 | `lattes_map_julia_set` | Lattes Map Julia Set | single_pass_escape_time | parameter_morph | reconcile_or_reference_family | candidate | targeted search: Lattès Map (degree 4, Weierstrass); Lattès Map (degree 9) |
| 5 | `modular_lambda_function_coloring` | Modular Lambda Function Coloring | single_pass_domain_coloring | phase_rotation | promoted_reference | promoted_reference | lambda_w (Lambda W Fractal) via lambda; lambda (Lambda Fractal) via lambda |
| 6 | `dedekind_eta_function_coloring` | Dedekind Eta Function Coloring | single_pass_domain_coloring | phase_rotation | promoted_reference | promoted_reference | none found in fuzzy scan |
| 7 | `schwarz_triangle_function_tessellation` | Schwarz Triangle Function Tessellation | single_pass_domain_coloring | parameter_morph | promoted_reference | promoted_reference | none found in fuzzy scan |
| 8 | `gamma_function_newton_fractal` | Gamma Function Newton Fractal | single_pass_root_finding | parameter_morph | promoted_reference | promoted_reference | newton_z8 (Newton z⁸−1) via newton; newton_z7 (Newton z⁷−1) via newton; newton_z6 (Newton z⁶−... |
| 9 | `newton_basins_for_trigonometric_equations` | Newton Basins for Trigonometric Equations | single_pass_root_finding | parameter_morph | promoted_reference | promoted_reference | f0003_mitchell_alternating_equations_newton (Mitchell Alternating-Equations Newton) via equat... |
| 10 | `householder_order_four_basin` | Householder Order Four Basin | single_pass_root_finding | parameter_morph | promoted_reference | promoted_reference | f0009_householder_s_method_3rd_order (Householder's Method (3rd Order)) via householder/order |
| 11 | `quasi_fuchsian_group_limit_set` | Quasi-Fuchsian Group Limit Set | raymarched_or_escape_limit_set | parameter_morph | reconcile_existing_reference | candidate | targeted search: Kleinian QuasiFuchsian 3D |
| 12 | `schottky_group_circle_inversion_limit_set` | Schottky Group Circle Inversion Limit Set | single_pass_or_raymarch | parameter_morph | reconcile_existing_reference | candidate | targeted search: Schottky Circle IFS; Kleinian Schottky 3D |
| 13 | `apollonian_sphere_packing_3d` | Apollonian Sphere Packing 3D | raymarched_sdf | camera_path | new_3d_reference_or_variant | candidate | f0289_apollonian_packing_ifs (Apollonian Packing IFS) via apollonian/packing |
| 14 | `coxeter_honeycomb_435_slice` | Coxeter Honeycomb 435 Slice | raymarched_sdf | camera_path | promoted_reference | promoted_reference | none found in fuzzy scan |
| 15 | `hyperbolic_honeycomb_534_slice` | Hyperbolic Honeycomb 534 Slice | raymarched_sdf | camera_path | promoted_reference | promoted_reference | none found in fuzzy scan |
| 16 | `dodecahedral_fold_fractal` | Dodecahedral Fold Fractal | raymarched_sdf | camera_path | promoted_reference | promoted_reference | none found in fuzzy scan |
| 17 | `4d_polychoron_fold_slice` | 4D Polychoron Fold Slice | raymarched_slice | parameter_morph | promoted_reference | promoted_reference | none found in fuzzy scan |
| 18 | `knot_complement_limit_set_visual` | Knot-Complement Limit-Set Visual | reference_first | camera_path | new_reference_research_only | candidate | none found in fuzzy scan |
| 19 | `rauzy_fractal_tribonacci_tile` | Rauzy Fractal Tribonacci Tile | procedural_geometry_or_reference | parameter_morph | reconcile_existing_reference | candidate | targeted search: Rauzy Fractal; Rauzy Fractal (L-system form); Rauzy Fractal Tiling; Rauzy Fr... |
| 20 | `paperfolding_curve_atlas` | Paperfolding Curve Atlas | procedural_geometry | growth_process | promoted_reference | promoted_reference | none found in fuzzy scan |
| 21 | `modular_tessellation_fundamental_domain` | Modular Tessellation Fundamental Domain | single_pass_geometry | parameter_morph | promoted_reference | promoted_reference | none found in fuzzy scan |
| 22 | `gaussian_prime_spiral` | Gaussian Prime Spiral | procedural_geometry | camera_path | new_reference_with_gaussian_lattice_dedup | candidate | targeted search: Gaussian Integer Lattice Fractal |
| 23 | `p_adic_julia_set_slice` | p-adic Julia Set Slice | reference_first | parameter_morph | new_reference_with_p_adic_dedup | candidate | targeted search: p-adic Fractal (p=3); p-adic Fractal (p=5) |
| 24 | `physarum_slime_mold_network` | Physarum Slime Mold Network | stateful_grid_or_particles | stateful_grid | new_reference_stateful | candidate | none found in fuzzy scan |
| 25 | `diffusion_limited_aggregation_crystal` | Diffusion-Limited Aggregation Crystal | stateful_particles_or_grid | growth_process | reconcile_or_new_stateful_variant | candidate | targeted search: DLA (Approximation) |

## Promotion notes by bucket

### App-near single-pass/math shader candidates

- **#1 Exponential Family Parameter Plane** (`exponential_family_parameter_plane`): Promoted reference-tier. Low overlap in registry scan; canonical transcendental-family parameter plane. Verify lambda*exp(z) formula and parameter-window conventions before registry insertion. Gate: shader compile + parameter-plane labels.
- **#2 Sine Family Parameter Plane** (`sine_family_parameter_plane`): Promoted reference-tier. Low overlap in registry scan; distinct from ordinary trigonometric coloring because it is an iterated transcendental parameter plane. Gate: shader compile + thumbnail proof.
- **#3 Baker Domain Exponential Map** (`baker_domain_exponential_map`): Promoted reference-tier. Low overlap in registry scan; reference-tier only until formula/source specificity is confirmed. Gate: formula provenance + bailout safety.
- **#4 Lattes Map Julia Set** (`lattes_map_julia_set`): Candidate / not yet in registry from this slice. Existing Lattès references are present; safest action is reconcile/enrich a Lattès family entry or add only a distinct Julia-set showcase alias, not a duplicate canonical entry. Gate: canonical formula + zoom/readability proof.
- **#5 Modular Lambda Function Coloring** (`modular_lambda_function_coloring`): Promoted reference-tier. Possible generic lambda-name collisions only; distinct modular lambda function entry if source/formula is verified. Gate: source + function approximation proof.
- **#6 Dedekind Eta Function Coloring** (`dedekind_eta_function_coloring`): Promoted reference-tier. Low overlap in registry scan; domain-coloring entry with series/convergence gate. Gate: series convergence + visual proof.
- **#7 Schwarz Triangle Function Tessellation** (`schwarz_triangle_function_tessellation`): Promoted reference-tier. Low overlap in registry scan; promote as reference first because shader feasibility is uncertain. Gate: formula + feasibility prototype.
- **#8 Gamma Function Newton Fractal** (`gamma_function_newton_fractal`): Promoted reference-tier. Newton-family overlap is expected but gamma-function roots/poles make this a distinct formula target. Gate: numerical stability + compile proof.
- **#9 Newton Basins for Trigonometric Equations** (`newton_basins_for_trigonometric_equations`): Promoted reference-tier. Overlap with Newton-family entries; promote as a family pack only, not one entry per equation preset. Gate: pole guards + domain window presets.
- **#10 Householder Order Four Basin** (`householder_order_four_basin`): Promoted reference-tier. Existing Householder 3rd-order reference found; order-4 should be distinct only if formula/order is explicit. Gate: formula + bounded iteration proof.

### Premium 3D / hyperbolic / high-dimensional candidates

- **#11 Quasi-Fuchsian Group Limit Set** (`quasi_fuchsian_group_limit_set`): Candidate / not yet in registry from this slice. Existing QuasiFuchsian/Kleinian reference is present; promote by enriching aliases/formula/renderer notes, not by adding a duplicate. Gate: dedup + formula clarity.
- **#12 Schottky Group Circle Inversion Limit Set** (`schottky_group_circle_inversion_limit_set`): Candidate / not yet in registry from this slice. Existing Schottky references are present; safe action is reconcile circle-inversion limit-set wording with existing Schottky entries. Gate: generator params + thumbnail proof.
- **#13 Apollonian Sphere Packing 3D** (`apollonian_sphere_packing_3d`): Candidate / not yet in registry from this slice. Related to 2D/IFS Apollonian entries; distinct only if explicitly 3D sphere packing/raymarch target. Gate: frame budget + compile proof.
- **#14 Coxeter Honeycomb 435 Slice** (`coxeter_honeycomb_435_slice`): Promoted reference-tier. Low overlap in registry scan; source-check Coxeter symbol and dimension before registry insertion. Gate: performance + accessible description.
- **#15 Hyperbolic Honeycomb 534 Slice** (`hyperbolic_honeycomb_534_slice`): Promoted reference-tier. Low overlap in registry scan; source-check Coxeter symbol and slice semantics. Gate: source + prototype.
- **#16 Dodecahedral Fold Fractal** (`dodecahedral_fold_fractal`): Promoted reference-tier. Low overlap in registry scan; fold-system formula/provenance needed before implementation. Gate: frame budget proof.
- **#17 4D Polychoron Fold Slice** (`4d_polychoron_fold_slice`): Promoted reference-tier. Low overlap in registry scan; reference-tier only until slice/projection semantics are exact. Gate: clear slice semantics.
- **#18 Knot-Complement Limit-Set Visual** (`knot_complement_limit_set_visual`): Candidate / not yet in registry from this slice. Low overlap in registry scan; high novelty but must not app-admit without a concrete mathematical construction. Gate: do not app-admit without formula/prototype.

### Tiling / number-theory / stateful animated candidates

- **#19 Rauzy Fractal Tribonacci Tile** (`rauzy_fractal_tribonacci_tile`): Candidate / not yet in registry from this slice. Rauzy is already represented; promote by deduping/enriching the substitution/Tribonacci construction rather than adding a new canonical entry. Gate: construction + dedup.
- **#20 Paperfolding Curve Atlas** (`paperfolding_curve_atlas`): Promoted reference-tier. Low overlap in registry scan; promote as atlas/family to avoid counting every fold preset separately. Gate: construction stage validation.
- **#21 Modular Tessellation Fundamental Domain** (`modular_tessellation_fundamental_domain`): Promoted reference-tier. Low overlap in registry scan; distinct from generic hyperbolic tiling if tied to PSL(2,Z) fundamental domain. Gate: source + coordinate proof.
- **#22 Gaussian Prime Spiral** (`gaussian_prime_spiral`): Candidate / not yet in registry from this slice. Gaussian integer lattice exists; Gaussian prime spiral is distinct only if primality visualization and lattice convention are explicit. Gate: primality bounds + visual proof.
- **#23 p-adic Julia Set Slice** (`p_adic_julia_set_slice`): Candidate / not yet in registry from this slice. p-adic references exist; a p-adic Julia slice is only safe as a distinct entry if a real p-adic dynamical-system construction is sourced. Gate: clear metric/model; no fake complex plot.
- **#24 Physarum Slime Mold Network** (`physarum_slime_mold_network`): Candidate / not yet in registry from this slice. Low overlap in registry scan; animation/stateful renderer gate before app visibility. Gate: state/performance proof.
- **#25 Diffusion-Limited Aggregation Crystal** (`diffusion_limited_aggregation_crystal`): Candidate / not yet in registry from this slice. DLA approximation exists; a crystal/growth entry should reconcile with it or remain a stateful-variant candidate until the model is explicit. Gate: stateful proof + deterministic seed.

## Source-check status

For promoted entries, source URLs were reachable during the slice and formula/construction notes were recorded in `formula_ast` fields. For the remaining Top-25 rows, this report still identifies source targets rather than final citations.

Before adding or editing more registry entries, each unpromoted row still needs:

- canonical English name and aliases;
- formula, construction, or algorithm written in project terms;
- at least one provenance source with license/citation notes;
- dedup decision against the targeted registry hit(s);
- reference-tier `formula_hash` generated from the normalized formula/construction;
- `implemented: false`, `tier: reference`, and no app-visible shader claim unless a shader actually exists.

## Recommended next registry-safe micro-batch

Promote another small source-verified reference-only batch, likely:

1. `apollonian_sphere_packing_3d` — only if kept distinct from existing 2D/IFS Apollonian entries.
2. `gaussian_prime_spiral` — only after distinguishing it from the Gaussian integer lattice reference.
3. `p_adic_julia_set_slice` — only with a real p-adic dynamics model, not a fake complex-plane Julia.
4. `physarum_slime_mold_network` — reference-only until stateful/particle renderer proof exists.
5. `diffusion_limited_aggregation_crystal` — reconcile with existing DLA approximation or keep as a stateful model target.

## Red lines

- Do not add these to implemented tier from this report.
- Do not add duplicate canonical entries where the action says reconcile/enrich.
- Do not count family packs as many entries until the schema distinguishes family, variation, preset, and renderer variant.
- Do not claim loopability, deep zoom, progressive accumulation, or stateful simulation without focused validation.
