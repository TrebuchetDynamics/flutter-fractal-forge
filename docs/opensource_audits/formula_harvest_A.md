# Formula Harvest A (opensource comparison)

## Scope

- Sources scanned: `par-fractal`, `shader-fractals`, `glChAoS.P`, `FractalExplorer`
- Compared against current IDs in `/home/xel/git/flutter-fractal-forge/lib/core/modules/builders/escape_time_catalog.dart` + module-registry custom IDs
- Current unique compared IDs: **338**
- Net candidate formulas in this harvest: **25**

## Key findings

- Strongest net-new cluster is from **par-fractal** (2D attractors + multiple 3D DE families).
- **glChAoS.P** adds several non-overlapping chaotic systems and 4D map extensions.
- **shader-fractals** contributes two non-canonical but visually distinct Menger derivatives.
- **FractalExplorer** mostly overlaps existing coverage (multibrot/multicorn/newton/polynomial forms).

## Suggested priority shortlist (implementation order)

- `martin` — Fast to add; same pipeline style as hopalong.
- `chip` — Distinct xfractint-style attractor, medium cost.
- `quadruptwo` — Companion to chip; shared code-path possible.
- `threeply` — Companion attractor; low additional engine risk.
- `octahedral_ifs` — High visual impact 3D DE fractal.
- `icosahedral_ifs` — Premium 3D geometry showcase fractal.
- `hybrid_mandelbulb_julia` — High-value flagship 3D formula.
- `quaternion_cubic_3d` — Natural extension of quaternion_julia_2d.
- `multichua_ii` — New chaotic family beyond current chua_circuit variant.
- `kings_dream` — Good low-complexity addition for attractor category.

## Candidate table

| proposed_id | source | family | GPU suitability | CPU complexity |
|---|---|---|---|---|
| `martin` | par-fractal | 2D strange attractor (iterative map) | High (compute-shader point accumulation) | Medium (O(points*iterations)) |
| `chip` | par-fractal | 2D strange attractor (hopalong variant) | High (same accumulation pipeline as hopalong) | Medium-high (log/trig heavy per step) |
| `quadruptwo` | par-fractal | 2D strange attractor (hopalong variant) | High (compute accumulation) | Medium-high (log/trig heavy) |
| `threeply` | par-fractal | 2D strange attractor (hopalong variant) | High (compute accumulation) | Medium (trig + abs per step) |
| `octahedral_ifs` | par-fractal | 3D IFS / distance-estimated fractal | Very high (ray-marching DE on fragment shader) | High (ray-march * DE iterations) |
| `icosahedral_ifs` | par-fractal | 3D IFS / kaleidoscopic DE fractal | Very high (GPU ray-marching; many plane folds) | High-very high |
| `hybrid_mandelbulb_julia` | par-fractal | 3D hybrid escape-time DE fractal | Very high (classic DE ray-march workload) | Very high |
| `quaternion_cubic_3d` | par-fractal | 3D quaternion Julia/deep escape-time | High (ray-march DE), math-heavy quaternion ops | Very high |
| `kleinian_3d` | par-fractal | 3D pseudo-kleinian / amazing-surface DE | Very high (DE ray-marching) | High |
| `sierpinski_gasket_3d` | par-fractal | 3D tetrahedral IFS + inversion | Very high (DE ray-marching) | High |
| `julia_quaternion_3d` | par-fractal | 3D quaternion Julia DE | Very high (DE ray-march) | Very high |
| `apollonian_gasket_3d` | par-fractal | 3D sphere-packing / inversion fractal | Very high (DE ray-marching) | High |
| `pickover_3d` | par-fractal | 3D strange attractor | High (compute cloud or DE cloud-distance approximation) | Medium-high |
| `lorenz_3d` | par-fractal | 3D ODE strange attractor | High (compute particle integration) | Medium-high |
| `rossler_3d` | par-fractal | 3D ODE strange attractor | High (compute particle integration) | Medium |
| `kings_dream` | glChAoS.P | 3D trig attractor map | High (compute map iterations / particle emit) | Medium |
| `sincos_3d` | glChAoS.P | 3D trigonometric coupled map | High (compute map iterations) | Medium |
| `multichua_ii` | glChAoS.P | 3D piecewise-linear ODE attractor | High (compute integration), moderate branch divergence due piecewise f(x) | High |
| `chen_celikovsky` | glChAoS.P | 3D ODE strange attractor | High (compute integration) | Medium |
| `popcorn_4d` | glChAoS.P | 4D map (Popcorn generalization) | High on compute (4D state to 3D projection rendering) | High |
| `mira_4d` | glChAoS.P | 4D Mira map extension | High on compute (iterative map) | Medium-high |
| `hopalong_4d` | glChAoS.P | 4D hopalong extension | High on compute | Medium |
| `kaneko_3d` | glChAoS.P | 3D iterative map / parametric slice | High (compute map iterations) | Medium |
| `menger_broccoli` | shader-fractals | 3D non-canonical SDF fractal (Menger-derivative) | Very high (SDF ray marching) | High |
| `menger_mushroom` | shader-fractals | 3D non-canonical SDF fractal (Menger-derivative) | Very high (SDF ray marching) | High |

## License notes by source

- `par-fractal`: **MIT**
- `shader-fractals`: **MIT**
- `glChAoS.P`: **BSD-2-Clause**
- `FractalExplorer`: no explicit license file found in repository root at scan time (treat as unknown for code-copy purposes).

## Output artifacts

- JSON: `/home/xel/git/flutter-fractal-forge/docs/opensource_audits/formula_harvest_A.json`
- Markdown: `/home/xel/git/flutter-fractal-forge/docs/opensource_audits/formula_harvest_A.md`
