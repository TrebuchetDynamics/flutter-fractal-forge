# Existing App Shader Linkage Audit

Conservative audit for generated existing-app source leads. This artifact does not promote entries or count presets.

## Summary

- Input ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.existing-app.json`
- Existing shader inventory: 478 `.frag` files
- Existing-app source leads: 848
- Exact declared shader matches: 0
- Basename shader matches elsewhere: 0
- Unresolved missing shader links: 848
- Shared-shader candidate leads: 355
- Still-unmapped leads: 493

## Unresolved by family

| Family | Count |
|---|---:|
| strange_attractors_maps | 289 |
| escape_time_polynomial_complex | 286 |
| cellular_automata | 146 |
| distance_estimated_3d_raymarch | 46 |
| ifs_geometric | 41 |
| number_theory_special_functions | 40 |

## Unresolved by renderer kind

| Renderer kind | Count |
|---|---:|
| point_accumulation | 289 |
| fragment_shader | 286 |
| grid_simulation | 186 |
| shader_or_app_renderer | 46 |
| point_mesh_accumulation | 41 |

## Shared-shader candidates by shader

These are not counted yet; they are implementation candidates that need reviewed parameter mapping and render smoke.

| Candidate shared shader | Leads |
|---|---:|
| `shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag` | 99 |
| `shaders/escape_time_family/core/julia_gpu.frag` | 56 |
| `shaders/escape_time_family/core/mandel_julia_dual_gpu.frag` | 44 |
| `shaders/strange_attractors/sprott_a_gpu.frag` | 34 |
| `shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag` | 25 |
| `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 20 |
| `shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag` | 14 |
| `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag` | 13 |
| `shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag` | 10 |
| `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag` | 9 |
| `shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag` | 9 |
| `shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag` | 6 |
| `shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag` | 3 |
| `shaders/cellular_and_stochastic/replicator_ca_gpu.frag` | 3 |
| `shaders/escape_time_family/core/phoenix_gpu.frag` | 3 |
| `shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag` | 2 |
| `shaders/cellular_and_stochastic/maze_ca_gpu.frag` | 2 |
| `shaders/cellular_and_stochastic/cyclic_ca_gpu.frag` | 2 |
| `shaders/cellular_and_stochastic/forest_fire_gpu.frag` | 1 |

## Next safe promotion actions

1. Do not count any existing-app source lead until its renderer path exists and validation passes.
2. Prioritize a shared-renderer strategy for `escape_time_polynomial_complex` source leads because they are numerous and use `EscapeTimeModule` defaults.
3. Add generated-module registration/render smoke only after shader paths are real or mapped to reviewed shared shaders.
4. Keep variants/presets excluded from counted totals unless a named stable formula/rule identity is promoted as its own module.
