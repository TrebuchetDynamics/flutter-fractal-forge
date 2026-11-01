# High-impact visual additions

Four entries join the catalog from the research pass in
`research/beautiful-fractals-next/report.md`. They were selected on
visual ceiling per GPU cycle and on identity: each one either uses an operator
or an algebra the catalog did not have, or it extends an existing genre in a
way the registry did not already queue.

| Catalog entry | Dimension | Shader | Research status |
| --- | --- | --- | --- |
| Imordial Brot (`imordial_brot`) | 3D | `shaders/3d_and_hypercomplex/raymarched_volumes/imordial_brot_gpu.frag` | New algebra; absent from catalog and reference ledger |
| Inversion Fold Lattice (`inversion_fold_lattice`) | 2D | `shaders/escape_time_family/experimental_named/rational_singularities/inversion_fold_lattice_gpu.frag` | New operator (reciprocal-radius fold); absent |
| Chladni Nodal Field (`chladni_nodal_field`) | 2D | `shaders/number_theory/chladni_nodal_field_gpu.frag` | New field; fifth member of the existing wave-field genre |
| Domain Warp Nebula (`domain_warp_nebula`) | 2D | `shaders/cellular_and_stochastic/domain_warp_nebula_gpu.frag` | New field; adjacent to `multifractal_plasma` |

## What each one is

**Imordial Brot.** Ray-marched escape set in Bristorian ("imordial") algebra,
which keeps ranked imaginary units under `e_a * e_b = sgn(b-a) * e_b` and
`e_a * e_a = -1`, so `e1*e2 = +e2` and `e2*e1 = -e1`. There is no `i*j = k`.
The algebra is non-commutative, non-associative and non-alternative, so it is a
different numbering system from the quaternion, bicomplex, split-complex and
tessarine slices already shipped. Because it is not associative, the cubic map
depends on bracketing, and both brackets ship as separate variants:

- `Quadratic` — `z² + c`, Mandelbrot family (`z0 = 0`, `dz/dc = 0`, `+dc` per step)
- `Quadratic Julia` — `z² + c` with the documented constant `(-0.7, -0.35, 0.05, 0)`
  (`z0 = seed`, `dz/dseed = 1`, no `+dc`)
- `Cubic (zz)z` — left-bracketed cubic
- `Cubic z(zz)` — right-bracketed cubic

Slot 9 (normally "Power") is the 4D section roll in degrees, labelled
`Section Roll`; the extra `4D Slice` control offsets the fourth algebra slot.
Distance estimate: `0.5 * log(r) * r / |dz|` with the derivative carried by the
bilinear product rule `J_square(z)v = z*v + v*z`, which needs no associativity.
The implementation was checked against the published `implSquare` terms
(maximum absolute difference `3.6e-15` over 2000 random 4-vectors).

Algebra reference and an MIT-licensed GLSL reference implementation:
<https://bristorbrot.org> and <https://github.com/dougbristor/bristorbrot>
(`core/bristor_product/v1.glsl`, `core/brot_de_march/v1.glsl`). This shader is an
independent implementation of the documented rule; no third-party shader source
was copied.

**Inversion Fold Lattice.** The map `p <- |p| / |p|² - c` with a small rotation
after each fold, coloured from the orbit trace. No other shader in the catalog
performs this operator: circle-inversion appears only as an inversion *group*
operation in the Kleinian and Schottky limit-set entries. Because the map is
largely convergent there is no escape time to colour by, so the shader uses
`log(1 + energy) / log(1 + iterations)` — a fixed divisor, so no per-image
normalisation is needed. The parameter family is uneven: structured lattices
appear near `c ≈ (1.0, 0.12)`, `(0.25, 0.12)`, `(0.38, 0.25)` and
`(0.25, 0.38)`, while several `c` values converge to a fixed point and render a
flat field. The four curated presets sit in the structured band.

**Chladni Nodal Field.** Superposed modal pairs
`cos(nπx)cos(mπy) - cos(mπx)cos(nπy)` with `1/k^0.85` amplitude, where the fine
modes are displaced by `tanh`-like saturation of a five-mode coarse field. The
displacement is what nests plate figures instead of repeating one symmetric
figure. Iterations select the modal count (6–40).

**Domain Warp Nebula.** Ridged fBm warped by itself twice: the first field
displaces the second, the second displaces the third. Iterations are a detail
budget — each fBm layer runs `iterations / 6` octaves (3–8).

## Validation

- `test/modules/high_impact_visuals_test.dart` covers registration, pubspec
  declaration, single-pass/sampler-free source boundaries, the researched
  operator tokens, `RenderAuditMetrics` health for every default and curated
  preset, control-responsiveness for every exposed parameter, preset
  distinctness, the four imordial variants, section-roll and 4D-slice
  responsiveness, and premultiplied alpha.
- Shader compilation is proven by `ui.FragmentProgram.fromAsset` in that test,
  which is why the registry records `quality.shader_compile.sksl: ok`. Hardware
  GLSL and device rendering remain unchecked.
- Registry entries record whole-file SHA-256 formula hashes; `forge doctor`
  passes with 1623 entries and no duplicate hashes.

Export 320 px review images without adding generated files to Git:

```bash
flutter test --dart-define=EXPORT_HIGH_IMPACT_VISUALS=true \
  test/modules/high_impact_visuals_test.dart \
  --plain-name 'export review images'
```

Images are written to the ignored `test/results/high-impact-visuals/`.

## Known limits

- The imordial distance estimate is heuristic (the algebra has no
  holomorphic derivative), so fin edges alias at small canvas sizes and thin
  structures produce sparse speckle in a still frame. The renderer's normal
  motion makes it read as texture rather than noise; supersampling was not
  added because 4× cost is not affordable at this step budget.
- Inversion Fold Lattice has structurally weak regions in its parameter plane;
  see above. It is not a full Mandelbrot-style parameter exploration.
- Chladni and Domain Warp Nebula are fields, not escape-time sets. They declare
  `uBailout` for the shared ABI and do not use it, like `talbot_fractal_carpet`.
- These are emulator/software-rasterized results. No physical-device or
  hardware-GPU qualification was performed.
