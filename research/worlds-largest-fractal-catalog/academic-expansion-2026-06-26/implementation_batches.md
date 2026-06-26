# Implementation batches

## Batch 1 — Low-risk cellular automata

Status: implemented for `rule90_linear_ca` and `rule150_linear_ca` using the shared elementary-rule shader.

Add:
- `rule90_linear_ca`
- `rule150_linear_ca`
- optionally one shared shader with `rule` uniform

Why first:
- no texture feedback required if rendered from formula/time row;
- no overlap with existing Rule 30;
- easy CPU fallback.

Validation:
- catalog identity test: IDs unique and shader asset exists;
- shader-source test: Rule 90 uses XOR of left/right; Rule 150 includes center;
- small CPU snapshot test: single-seed Rule 90 row counts match Pascal mod 2 for first 8 rows.

## Batch 2 — Excitable cellular automata

Status: implemented for `cyclic_cellular_automaton` and `greenberg_hastings_ca` with focused registration, shader-compile, and CPU-step tests.

Add:
- `cyclic_cellular_automaton`
- `greenberg_hastings_ca`

Why second:
- still simple local-neighborhood rules;
- visually distinct from Wireworld and Life-like entries.

Validation:
- parameter tests for `states`, `threshold`, `refractoryPeriod`;
- deterministic 8×8 CPU step tests;
- shader uniform contract test.

## Batch 3 — Lattès rational map

Status: implemented for `lattes_map_julia` with a pole-guarded rational-map shader and native CPU fallback.

Add:
- `lattes_map_julia`

Why third:
- one fragment shader, no texture feedback;
- fills rational complex dynamics gap.

Validation:
- pole guard source test;
- CPU/GPU formula parity on sampled points away from poles;
- catalog search finds `Lattès` and `Lattes`.

## Batch 4 — Klausmeier vegetation patterns

Status: implemented for `klausmeier_vegetation` as a static explicit-iteration shader with a finite CPU cell-step test.

Add:
- `klausmeier_vegetation`

Why fourth:
- requires reaction-diffusion update path / ping-pong texture if animated;
- can ship static iterative shader first.

Validation:
- finite-difference CPU step test on 8×8 grid;
- parameter clamp tests for `A`, `B`, diffusion, advection;
- visual smoke: nonuniform seed remains finite after 32 steps.

## Batch 5 — Substitution tiling family

Status: implemented for `arnoux_rauzy_fractal` and `dual_substitution_tiling` with shader registration, compile tests, and symbolic substitution helper tests.

Add one at a time:
- `arnoux_rauzy_fractal`
- `dual_substitution_tiling`

Why later:
- overlaps conceptually with existing Rauzy/Tribonacci entries;
- needs identity text and duplicate guardrails.

Validation:
- generated prefix/substitution word tests;
- duplicate-name test against existing catalog IDs/names;
- CPU precompute path produces bounded projected points.

## Hold / research before coding

- Parametric root-finding basin family: extract exact formula from paper metadata/full bibliographic source first; do not invent `Phi_alpha`.
- Combined root-finding dynamics: implement only if the combined method is mathematically distinct from existing Newton/Halley/Chebyshev/King/Jarratt entries.
- Self-replicating reaction-diffusion spots: likely a preset unless kinetics differ from existing Gray-Scott entries.
