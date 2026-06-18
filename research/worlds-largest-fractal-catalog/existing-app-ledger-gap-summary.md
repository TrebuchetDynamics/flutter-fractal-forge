# Existing App Ledger Gap Summary

## Purpose

Measure how much of the existing generated app metadata can safely count toward the 5,000–10,000 curated renderable entry objective without counting random presets.

## Generated artifact

- Ledger: `curated-entry-ledger.existing-app.json`
- Generator: `generate_existing_app_ledger.py`
- Validator: `validate_catalog_goal.py --entries research/worlds-largest-fractal-catalog/curated-entry-ledger.existing-app.json`

## Result

The generator found **848 metadata + thumbnail source leads**. It counted **0 promoted entries** because every discovered generated module declared a shader path that does not currently exist at that path.

This is correct count hygiene: thumbnails and metadata prove useful catalog leads, but they do not prove a currently renderable formula/rule entry until the renderer path is valid and validation passes.

## Family breakdown

| Family | Source leads | Counted promoted entries |
|---|---:|---:|
| strange_attractors_maps | 289 | 0 |
| escape_time_polynomial_complex | 286 | 0 |
| cellular_automata | 146 | 0 |
| distance_estimated_3d_raymarch | 46 | 0 |
| ifs_geometric | 41 | 0 |
| number_theory_special_functions | 40 | 0 |
| **Total** | **848** | **0** |

## Promotion blocker

All 848 source leads include this validation signal:

- `declared shader asset missing`

Example pattern: generated module metadata and thumbnail exist, but the module declares `shaders/<id>_gpu.frag` and no matching shader asset exists at that path.

A follow-up shader-linkage audit now exists:

- JSON: `existing-app-shader-linkage-audit.json`
- Markdown: `existing-app-shader-linkage-audit.md`
- Non-counting promotion plan: `shared-renderer-promotion-plan.json` / `shared-renderer-promotion-plan.md`
- Julia shared mapping worklist: `julia-shared-mapping-worklist.json` / `julia-shared-mapping-worklist.md`
- Sprott shared mapping worklist: `sprott-shared-mapping-worklist.json` / `sprott-shared-mapping-worklist.md`
- Phoenix shared mapping worklist: `phoenix-shared-mapping-worklist.json` / `phoenix-shared-mapping-worklist.md`
- Elementary CA shared mapping worklist: `elementary-ca-shared-mapping-worklist.json` / `elementary-ca-shared-mapping-worklist.md`
- Mandelbrot shared mapping worklist: `mandelbrot-shared-mapping-worklist.json` / `mandelbrot-shared-mapping-worklist.md`
- Orbit-trap shared mapping worklist: `orbit-trap-shared-mapping-worklist.json` / `orbit-trap-shared-mapping-worklist.md`
- Multibrot shared mapping worklist: `multibrot-shared-mapping-worklist.json` / `multibrot-shared-mapping-worklist.md`
- 3D shared mapping worklist: `3d-shared-mapping-worklist.json` / `3d-shared-mapping-worklist.md`
- Escape-variant shared mapping worklist: `escape-variant-shared-mapping-worklist.json` / `escape-variant-shared-mapping-worklist.md`
- Residual CA shared mapping worklist: `residual-ca-shared-mapping-worklist.json` / `residual-ca-shared-mapping-worklist.md`
- Shared-renderer duplicate-risk audit: `shared-renderer-duplicate-risk-audit.json` / `shared-renderer-duplicate-risk-audit.md`
- Shared-renderer ready backlog: `shared-renderer-ready-backlog.json` / `shared-renderer-ready-backlog.md`
- Shared-renderer ready backlog validator: `validate_shared_renderer_ready_backlog.py`
- Shared-renderer implementation batches: `shared-renderer-implementation-batches.json` / `shared-renderer-implementation-batches.md`
- Shared-renderer implementation batch validator: `validate_shared_renderer_implementation_batches.py`
- Shared-renderer semantic-support audit: `shared-renderer-semantic-support-audit.json` / `shared-renderer-semantic-support-audit.md`
- Semantic-supported implementation batches: `semantic-supported-implementation-batches.json` / `semantic-supported-implementation-batches.md`

Latest audit result:

- exact declared shader matches: 0
- basename shader matches elsewhere: 0
- unresolved missing shader links: 848
- conservative shared-shader candidate leads: 355
- still-unmapped leads: 493

The expanded shader-linkage audit now finds 355 shared-shader implementation candidates across 19 shader batches. Detailed worklists cover all 355 shared-shader candidates: 99 Elementary CA, 56 Julia-style, 44 Mandelbrot-family, 39 escape variants (tricorn/burning-ship/sine/cosine), 34 Sprott-style, 27 3D, 25 orbit-trap, 20 Multibrot, 8 residual CA/stochastic, and 3 Phoenix-style leads. The reviewed shared-Julia promotion registered all 50 parseable fixed-`c` formula identities into the live registry, the Phoenix promotion registered all 3 parsed degree identities, the exact-Sprott promotion registered Sprott C with its exact shader, the 3D promotion registered 18 unique Mandelbox-scale/Mandelbulb-power identities while excluding duplicate Mandelbox scale aliases and unsupported quaternion/KIFS constants, the residual CA promotion registered 7 cyclic/birth-survival rule identities, the Elementary CA promotion registered all 99 parsed Wolfram rule identities, and the Multibrot promotion registered 18 parsed exponent identities, two Mandelbrot power identities were mapped through the same parameterized shader, the escape-power promotion registered 17 Tricorn/Burning Ship exponent identities, the escape-expression promotion registered 14 unique sine/cosine expression identities while intentionally excluding duplicate expression-token aliases and the ambiguous Möbius token, the orbit-trap promotion registered 24 stable trap-geometry identities while excluding the duplicate cross trap, the forest-fire CA rule was promoted, and the 3D promotion added 3 Quaternion Julia constants plus 2 KIFS/Menger family identities; the reviewed Möbius rational-map expression and 10 direct transcendental formulas were also promoted, including tan(z²)+c, sech(z)+c, and tanh(z²)+c variants; 7 additional exp/log/tan expression formulas were promoted while excluding duplicate aliases, and 28 explicit outer-totalistic B/S cellular-automata rules were promoted via the reviewed birth/survival mask renderer, and 3 fixed named CA rules (Wireworld, Brian’s Brain, Hodgepodge Machine) were promoted through direct matching shaders, and 41 supported fractal-flame variation rules (V0–V40) were promoted after adding shader support for the remaining standard variation formulas, and 1 parameterized Weierstrass function identity (a=0.3,b=7) was promoted, plus 2 direct 3D KIFS identities (Sierpinski tetrahedron and 3D Koch snowflake), and 22 additional thumbnail-backed Elementary CA rule identities, and 14 exact Sprott strange-attractor formula identities, and 8 named Life-like B/S cellular-automaton rule identities, and 42 exact strange-attractor formula/map identities, and 32 Clifford coefficient-map identities, and 20 Svensson coefficient-map identities, and 13 Martin/Hopalong coefficient-map identities, and 22 Peter de Jong coefficient-map identities, and 6 Lozi coefficient-map identities, and 4 unique Tinkerbell a-coefficient identities, and 16 Gumowski-Mira coefficient-map identities, and 6 exact escape/root/orbit formula identities, and 3 Standard Map K identities, and 4,200 systematic Life-like B/S rule identities. The residual CA worklist parses 8 birth/survival, cyclic-state, or stochastic rule mappings. The Julia worklist extracts parseable `c` constants for 50 of 56 Julia-style leads. The Mandelbrot worklist extracts 19 ready period/view-region mappings and flags 25 formula variants for renderer review. The orbit-trap worklist parses 25 stable trap-geometry identities. The Multibrot worklist parses 18 exponent/power identities and flags 2 for manual review. The 3D worklist parses 27 parameter mappings across Mandelbox scale, Mandelbulb power, Quaternion Julia constants, and KIFS/Menger family hints. The escape-variant worklist parses 37 ready mappings across tricorn, burning-ship, sine, and cosine families. The Sprott worklist identifies 15 of 34 Sprott-style leads with exact live shader counterparts and 19 needing equation/coefficient mapping. The Phoenix worklist parses degree overrides for all 3 Phoenix-style leads. Duplicate-risk audit for those detailed worklists now marks 287 candidates as already represented by counted live modules, leaving 68 non-duplicate candidates; the ready backlog narrows this to 20 non-duplicate, mapping-ready implementation candidates (1 escape variant, 19 Mandelbrot view-region candidates). None of the remaining candidates are counted until a reviewed shared renderer mapping is implemented and render-smoke validation passes.

## Next concrete action

Choose one family and create a renderer-link promotion batch:

1. Resolve shader path strategy for generated modules: create shader assets, update declared paths, or map to shared family shaders.
2. For each batch item, keep formula/rule identity from metadata and ignore presets.
3. Validate renderer path + thumbnail path + provenance source.
4. Flip `counted_entry=true` only after `validate_catalog_goal.py` passes.

Recommended next batch: add shader or mapper extension support for one remaining family, starting with forest-fire CA, orbit-trap geometry, Mandelbrot period/view-region mapping, or the 5 remaining 3D quaternion/KIFS candidates, then render-smoke before promotion. The stricter semantic audit now finds 0 immediate candidates and 20 mapping-ready candidates that still need shader or mapper extensions before their formula/rule identity can be distinguished by the shared renderer. Run `validate_shared_renderer_ready_backlog.py`, `validate_shared_renderer_implementation_batches.py`, and `audit_shared_renderer_semantic_support.py` before promotion work.

## Completion impact

The reviewed shared-Julia, Phoenix, exact-Sprott, 3D, residual CA, Elementary CA, and Multibrot promotions contributed **196** promoted live entries. The active live-registry ledger currently counts **638** promoted entries, still far below 5,000. The remaining discovered existing-app leads are useful backlog, not objective completion.
