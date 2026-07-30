# Targeted research: classical Tetrabrot 3D

## Scope

This follow-up starts from the audited 25-identity catalog and searches for a named higher-algebraic 3D fractal with an exact slice and distance construction. Six ResearchForge queries across OpenAlex, Crossref, and arXiv returned 254 records (30/104/120 by source) and 110 unique DOIs.

## Accepted identity

The classical quadratic Tetrabrot is the principal 3D slice

`T²(1, i₁, i₂)`

of the tricomplex Mandelbrot set. A point is represented as

`c = x + y i₁ + z i₂`,

and belongs when the orbit of zero under `Q_(2,c)(η)=η²+c` remains bounded.

The idempotent decomposition reduces this to two ordinary complex Mandelbrot parameters:

- `c₋ = x + (y-z)i`
- `c₊ = x + (y+z)i`

The Tetrabrot contains `(x,y,z)` exactly when both `c₋` and `c₊` belong to the complex Mandelbrot set. The tricomplex distance construction combines the two component distances as

`sqrt((d(c₋,M)² + d(c₊,M)²) / 2)`.

Evidence:

- Parisé, Brouillette, and Rochon define principal 3D tricomplex slices, identify `T²(1,i₁,i₂)` as the classical Tetrabrot, derive the two complex components, and provide the component-distance formula ([arXiv:1811.09697](https://arxiv.org/abs/1811.09697), [DOI 10.1142/S0218127419500858](https://doi.org/10.1142/S0218127419500858)).
- Rochon specifically develops bicomplex distance estimation for ray-traced 3D Tetrabrot slices ([DOI 10.1142/S0218127405013873](https://doi.org/10.1142/S0218127405013873)).
- Brouillette and Rochon classify the named principal 3D slices of the tricomplex Mandelbrot set ([arXiv:2107.04016](https://arxiv.org/abs/2107.04016), [DOI 10.3390/math10030482](https://doi.org/10.3390/math10030482)).

## Identity decision

`tetrabrot_3d` is not a power preset or an alias of the planar Mandelbrot module. It is a three-dimensional principal slice in a commutative tricomplex algebra, with membership requiring the intersection of two coupled complex parameter conditions. It is also distinct from the quaternion Mandelbrot slice, whose multiplication, symmetry, and orbit representation differ.

Only the classical quadratic slice is added. Higher powers, Arrowheadbrot, Mousebrot, Turtlebrot, Hourglassbrot, Metabrot, Airbrot, and Firebrot remain separate research candidates; none are treated as presets or silently bundled.

## Implementation decision

- Add one stable ID and one local standard-layout ray-marching shader.
- Hide the generic power control because this identity is fixed at `p=2`.
- Compute each complex Mandelbrot distance estimate independently and combine them using the published idempotent distance expression.
- Add an independent CPU membership oracle for `(0,0,0)`, `(-1,0,0)`, and `(2,0,0)`.
- Describe the shader distance as an estimator; image health does not prove exact boundary distance.

## Claim hygiene

The arXiv abstract and open TeX source were inspected to recover the explicit slice equations; no full text or third-party rendering code is stored in the repository. The implementation is fresh local GLSL. The catalog name refers only to the classical quadratic Tetrabrot, not every tricomplex Mandelbrot slice.
