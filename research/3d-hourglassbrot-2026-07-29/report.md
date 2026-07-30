# Hourglassbrot 3D evidence extraction

## Method and limits

This focused extraction reuses the checksum-locked comprehensive package `research/3d-principal-tricomplex-slices-2026-07-29/` instead of repeating live retrieval. That corpus already includes 27 queries across OpenAlex, arXiv, and Crossref, 475 records, 174 unique DOIs, and three citation expansions with 37 edges. `source-corpus.json` verifies five exact parent artifacts.

The public HTML for arXiv:2107.04016 was re-inspected at Proposition 8 and its preceding Arrowheadbrot proposition. No PDF, TeX source, full text, or third-party renderer code is stored in the repository.

## Bottom line

The classical quadratic **Hourglassbrot** is a named principal 3D slice with a rule distinct from Arrowheadbrot and Turtlebrot. Vallières and Rochon identify it as `T(i₁,j₁,j₂)`, where `j₁=i₁i₂` and `j₂=i₁i₃`, and Proposition 8 proves that it is the intersection of an Arrowheadbrot-related slice and its reflection across the third-coordinate plane.

Recursive idempotent decomposition yields four ordinary complex Mandelbrot parameters with common imaginary part `x` and all real sign combinations of `y` and `z`. Requiring all four components to remain bounded is a separate intersection identity, not a camera or color preset.

## Exact derivation

Use coordinates

`c = x i₁ + y j₁ + z j₂`.

Proposition 8 maps the two reflected tricomplex components to Arrowheadbrot-related bicomplex parameters with real coordinate `±z`, imaginary coordinate `x`, and hyperbolic coordinate `y`. Applying the Arrowheadbrot idempotent decomposition to both signs produces:

1. `( y-z) + xi`;
2. `(-y+z) + xi`;
3. `( y+z) + xi`;
4. `(-y-z) + xi`.

The quadratic orbit of zero is bounded exactly when all four complex component orbits are bounded. Two levels of the published idempotent Euclidean norm combine component estimates as

`sqrt((d₀²+d₁²+d₂²+d₃²)/4)`.

Primary source:

- Vallières and Rochon, *Relationship between the Mandelbrot Algorithm and the Platonic Solids* (Mathematics, 2022), Proposition 8: gives the basis `T(i₁,j₁,j₂)`, reflected Arrowheadbrot-copy intersection, and reflection plane. Proposition 3 supplies the Arrowheadbrot component rule. [arXiv:2107.04016](https://arxiv.org/abs/2107.04016), [DOI 10.3390/math10030482](https://doi.org/10.3390/math10030482).

Supporting algebra:

- Brouillette and Rochon, *Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set* (Advances in Applied Clifford Algebras, 2019): recursive idempotent decomposition, componentwise Multibrot membership, and Euclidean norm. [arXiv:1809.02020](https://arxiv.org/abs/1809.02020), [DOI 10.1007/s00006-019-0956-1](https://doi.org/10.1007/s00006-019-0956-1).

## Independent identity checks

The CPU oracle compares Hourglassbrot, the correctly remapped Arrowheadbrot parent copy, Turtlebrot, Mousebrot, Arrowheadbrot, and Tetrabrot:

1. `(0,0,0)` belongs to all six.
2. `(-1/2,-1/4,-1/4)` belongs to the Arrowheadbrot parent copy but fails the reflected intersection, so it is outside Hourglassbrot. This witnesses strict containment.
3. `(1/2,-1/4,0)` belongs to Hourglassbrot and its parent but is outside Turtlebrot, Mousebrot, Arrowheadbrot, and Tetrabrot in their catalog coordinates.

These checks are independent CPU complex iterations, not shader samples.

## Identity decision

Accepted stable ID: `hourglassbrot_3d`.

- Fixed at classical quadratic degree `p=2`.
- Four-component reflected-intersection rule, not an Arrowheadbrot preset.
- No powers, alternate reflections, palettes, camera views, or fixed constants become IDs.
- One standard-layout local shader and one comparative CPU oracle.

## Claim hygiene and evidence gaps

- Proposition 8 states the basis and intersection; the four final complex equations require the documented substitution into Proposition 3 rather than appearing as a numbered four-line formula.
- Root-mean-square component estimates are a conservative rendering construction, not an exact signed-distance theorem.
- Finite-iteration rational witnesses are regression evidence, not a general Mandelbrot-membership decision procedure.
- Metabrot remains a separate basis and is not exposed as an Hourglassbrot preset.
