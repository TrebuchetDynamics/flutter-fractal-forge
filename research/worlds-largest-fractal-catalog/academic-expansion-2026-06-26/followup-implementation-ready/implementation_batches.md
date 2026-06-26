# Implementation batches

## Batch A — Shader-only deterministic fractals

Status: implemented.

Added:
- `bedford_mcmullen_carpet`
- `complex_henon_julia_slice`

Validation:
- catalog IDs unique;
- shader assets registered in `pubspec.yaml`;
- CPU helper tests for Bedford digit membership and Hénon one-step recurrence;
- shader compile smoke tests.

## Batch B — Spatiotemporal chaos fields

Status: implemented.

Added:
- `coupled_logistic_map_lattice`
- `matrix_logistic_spectrum`

Validation:
- deterministic coupled-logistic CPU step test;
- shader compile smoke tests;
- registered CPU fallback formulas.

## Batch C — Named reaction-diffusion/ecological models

Status: implemented.

Added:
- `mimura_murray_predator_prey`
- `stable_square_turing_model`

Validation:
- shader uniform contract covers kinetic parameters;
- shader compile smoke tests;
- registered CPU fallback formulas.

## Batch D — Continuous CA / texture-feedback work

Status: implemented as static/prototype shader pending future stateful ping-pong renderer.

Added:
- `flow_lenia`

Validation:
- one-kernel CPU growth test;
- shader compile smoke test;
- registered CPU fallback formula.

## Batch E — Advanced/specialized candidates

Status: implemented as minimal/prototype modules where full-fidelity engines were out of scope.

Added:
- `higher_order_root_basin_family`
- `gerhardt_schuster_tyson_ca`
- `implicit_affine_fractal_surface`

Already present/validated:
- `hofstadter_butterfly`

Validation:
- shader compile smoke tests;
- source-formula checks;
- catalog registration and shader asset tests.
