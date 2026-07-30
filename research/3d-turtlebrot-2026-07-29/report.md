# Turtlebrot 3D evidence extraction

## Method and limits

This focused extraction reuses two checksum-locked packages rather than repeating live retrieval:

- `research/3d-principal-tricomplex-slices-2026-07-29/`: 27 queries, OpenAlex/arXiv/Crossref, 475 records, 174 unique DOIs, three citation seeds and 37 edges;
- `research/3d-mousebrot-2026-07-29/`: the exact two-component Mousebrot derivation used below.

`source-corpus.json` records eight verified input checksums. The public HTML for arXiv:2107.04016 was re-inspected at Proposition 7. No PDF, TeX source, full text, or third-party rendering code is stored in the repository.

## Bottom line

The classical quadratic **Turtlebrot** is a defensible identity distinct from Mousebrot. Vallières and Rochon identify it as `T(i₁,i₂,j₂)`, where `j₂=i₁i₃`, and Proposition 7 proves that it is the intersection of a Mousebrot-related slice and its reflection across the third-coordinate plane.

Recursively applying the published tricomplex and bicomplex idempotent decompositions yields four ordinary complex Mandelbrot parameters. Requiring all four to remain bounded makes Turtlebrot a strict subset rule rather than a camera or palette variant of Mousebrot.

## Exact derivation

Use

`c = x i₁ + y i₂ + z j₂ = x i₁ + y i₂ + (z i₁)i₃`.

Proposition 7 decomposes this tricomplex number into the bicomplex parameters

- `x i₁ + y i₂ - z j₁`;
- `x i₁ + y i₂ + z j₁`.

Each is a Mousebrot-related bicomplex parameter. Applying the bicomplex idempotent identity to both signs gives four ordinary complex parameters:

1. `-z + (x-y)i`;
2. ` z + (x+y)i`;
3. ` z + (x-y)i`;
4. `-z + (x+y)i`.

The quadratic orbit of zero is bounded exactly when all four complex component orbits are bounded. Two recursive idempotent Euclidean norms combine component distance estimates as

`sqrt((d₀²+d₁²+d₂²+d₃²)/4)`.

Primary source:

- Vallières and Rochon, *Relationship between the Mandelbrot Algorithm and the Platonic Solids* (Mathematics, 2022), Proposition 7: defines `T(i₁,i₂,j₂)` as the intersection of the two reflected Mousebrot-related slices and explicitly describes the reflection. [arXiv:2107.04016](https://arxiv.org/abs/2107.04016), [DOI 10.3390/math10030482](https://doi.org/10.3390/math10030482).

Supporting algebra:

- Brouillette and Rochon, *Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set* (Advances in Applied Clifford Algebras, 2019): recursive idempotent representation, componentwise Multibrot membership, and Euclidean norm. [arXiv:1809.02020](https://arxiv.org/abs/1809.02020), [DOI 10.1007/s00006-019-0956-1](https://doi.org/10.1007/s00006-019-0956-1).

## Independent identity checks

The CPU oracle evaluates Turtlebrot, Mousebrot, Arrowheadbrot, and Tetrabrot formulas at common coordinates:

1. `(0,0,0)` belongs to all four.
2. `(1/8,-3/4,-1/8)` belongs to Mousebrot but fails one of the reflected components, so it is outside Turtlebrot (and outside Arrowheadbrot/Tetrabrot). This witnesses that Turtlebrot is a strict subset of Mousebrot.
3. `(-3/4,-1/4,0)` belongs to Turtlebrot and Mousebrot but not Arrowheadbrot or Tetrabrot, separating the rule from those existing slices.

All expectations are computed by independent CPU complex iteration, not by sampling the shader.

## Identity decision

Accepted stable ID: `turtlebrot_3d`.

- Fixed at the classical quadratic degree `p=2`.
- Four-component reflected-intersection rule, not a Mousebrot preset.
- No alternate reflection, power, palette, camera, or fixed-value IDs.
- Standard-layout local shader plus comparative CPU oracle.

## Claim hygiene and evidence gaps

- The source explicitly supplies the basis and reflected-intersection theorem; the four complex equations are a transparent recursive substitution into the cited idempotent identities rather than a separately numbered list in Proposition 7.
- Root-mean-square component estimates are suitable for conservative rendering but are not an exact signed-distance theorem for every boundary point.
- Finite iteration at the selected rational witnesses is independent regression evidence, not a general Mandelbrot-membership decision procedure.
- Hourglassbrot has an analogous intersection statement but a different basis and parent slice; it is not included as a Turtlebrot view or preset.
