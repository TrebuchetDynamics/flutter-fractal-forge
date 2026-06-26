# Implementation batches

## Batch A — Shader-only deterministic fractals

Add first:
- `bedford_mcmullen_carpet`
- `complex_henon_julia_slice`

Why:
- no persistent texture feedback;
- formulas are compact;
- distinct from existing Sierpinski carpets and real Hénon attractor.

Validation:
- catalog IDs unique;
- shader assets registered in `pubspec.yaml`;
- CPU helper tests for Bedford digit membership and Hénon one-step recurrence;
- shader compile smoke tests.

## Batch B — Spatiotemporal chaos fields

Add:
- `coupled_logistic_map_lattice`
- optional `matrix_logistic_spectrum` prototype

Why:
- still local/math-only;
- adds time-vs-space dynamical fields.

Validation:
- deterministic row-step CPU test;
- parameter clamp tests for `r`, `coupling`, `iterations`;
- no NaN/Inf after 256 simulated cells.

## Batch C — Named reaction-diffusion/ecological models

Add:
- `mimura_murray_predator_prey`
- optionally `stable_square_turing_model`

Why:
- cited named kinetics;
- broader than existing Gray-Scott/Klausmeier chemistry/ecology coverage.

Validation:
- 8×8 finite-difference CPU step remains finite;
- shader uniform contract covers each kinetic parameter;
- preset names include cited model identity.

## Batch D — Continuous CA / texture-feedback work

Add after stateful renderer support is confirmed:
- `flow_lenia`

Why later:
- needs ping-pong texture/state support for faithful evolution;
- do not fake it as a static noise shader.

Validation:
- one-kernel CPU convolution/growth test;
- mass-conservation smoke check;
- texture-state renderer integration test.

## Batch E — Advanced/specialized candidates

Hold until exact formulas or prototypes are available:
- `higher_order_root_basin_family`
- `gerhardt_schuster_tyson_excitable_ca`
- `implicit_affine_fractal_surface`
- `hofstadter_butterfly`

Why:
- root-finding family needs exact paper update formula;
- Gerhardt-Schuster-Tyson overlaps current excitable CA unless curvature/dispersion is implemented;
- implicit affine surfaces need performance proof;
- Hofstadter needs CPU precompute or q-limited numerical shader.
