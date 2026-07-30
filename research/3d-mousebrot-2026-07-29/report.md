# Mousebrot 3D evidence extraction

## Method and limits

This is a focused extraction from the immediately preceding comprehensive package `research/3d-principal-tricomplex-slices-2026-07-29/`, not a repeated live search. That package already contains 27 queries across OpenAlex, arXiv, and Crossref, 475 saved records, 174 combined unique DOIs, and citation expansion for the defining principal-slice papers. `source-corpus.json` records checksums for the exact reused artifacts.

The public HTML for arXiv:2107.04016 and arXiv:1809.02020 was re-inspected to verify the figure-to-name mapping and the general idempotent identity. No PDF, TeX source, full text, or third-party renderer code is stored here.

## Bottom line

The classical quadratic **Mousebrot** is a named principal 3D slice distinct from Tetrabrot and Arrowheadbrot. Vallières and Rochon identify Mousebrot as Figure 3(c), whose caption gives the basis `T(i₁,i₂,j₁)`; applying the published bicomplex idempotent identity to `c=x i₁+y i₂+z j₁` yields complex components `z+(x-y)i` and `-z+(x+y)i`.

The two components create membership results that differ from both existing principal slices at simple independently iterated points, so Mousebrot is not a camera rotation, palette, or fixed parameter variant.

## Exact derivation

Let `j₁=i₁i₂` and use coordinates

`c = x i₁ + y i₂ + z j₁ = x i₁ + (y+z i₁)i₂`.

Brouillette and Rochon's general idempotent representation for a bicomplex number `η=η₁+η₂i₂` is

`η = (η₁-η₂i₁)γ₁ + (η₁+η₂i₁)γ̄₁`,

where `γ₁=(1+j₁)/2` and `γ̄₁=(1-j₁)/2`. Substitution gives

- `c₋ = z + (x-y)i₁`;
- `c₊ = -z + (x+y)i₁`.

Orthogonality of the idempotents makes the quadratic orbit of zero bounded exactly when both ordinary complex Mandelbrot component orbits are bounded. Their published Euclidean norm gives the component-distance combination

`sqrt((d(c₋,M)²+d(c₊,M)²)/2)`.

Sources:

- Vallières and Rochon, *Relationship between the Mandelbrot Algorithm and the Platonic Solids* (Mathematics, 2022): names Mousebrot as Figure 3(c), whose caption is `T(i₁,i₂,j₁)`. [arXiv:2107.04016](https://arxiv.org/abs/2107.04016), [DOI 10.3390/math10030482](https://doi.org/10.3390/math10030482).
- Brouillette and Rochon, *Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set* (Advances in Applied Clifford Algebras, 2019): defines principal slices, idempotent decomposition, componentwise Multibrot membership, and the idempotent Euclidean norm. [arXiv:1809.02020](https://arxiv.org/abs/1809.02020), [DOI 10.1007/s00006-019-0956-1](https://doi.org/10.1007/s00006-019-0956-1).
- Martineau and Rochon, *On a Bicomplex Distance Estimation for the Tetrabrot* (International Journal of Bifurcation and Chaos, 2005): component distance-estimator precedent for ray-traced bicomplex slices. [DOI 10.1142/S0218127405013873](https://doi.org/10.1142/S0218127405013873).

## Independent identity checks

The CPU oracle evaluates Mousebrot, Arrowheadbrot, and Tetrabrot component formulas at the same coordinates:

1. `(0,0,0)` belongs to all three.
2. `(-3/4,-1/4,0)` maps in Mousebrot to `-i/2` and `-i`, both bounded at the stable oracle depth; the same coordinate is outside Arrowheadbrot and Tetrabrot.
3. `(-2,0,0)` maps in Mousebrot to `-2i` twice and escapes, while it maps to the real Mandelbrot endpoint `-2` in both Arrowheadbrot and Tetrabrot.

Thus at least two witnessed membership differences separate the identities independently of rendered appearance.

## Identity decision

Accepted stable ID: `mousebrot_3d`.

- Fixed at quadratic degree `p=2`.
- No higher powers, memory recurrences, palettes, camera views, or constants become IDs.
- Uses one standard-layout local shader and one CPU oracle.
- Does not subsume Turtlebrot: the source describes Turtlebrot as an intersection involving reflected Mousebrot-related slices, a distinct rule requiring separate derivation.

## Claim hygiene and gaps

- The complex derivative formula and root-mean-square component norm form a rendering distance estimator, not a proof of exact signed distance to every boundary point.
- Finite iteration is used only for stable selected witnesses; it is not a general decision procedure for Mandelbrot membership.
- The Mousebrot name-to-basis link is carried by the paper's text (`Mousebrot`, Figure 3(c)) and Figure 3 caption (`T(i₁,i₂,j₁)`), while the component equations are an explicit substitution into the paper's general idempotent identity rather than a separately numbered Mousebrot proposition.
- Remaining named slices require their own basis/component/oracle audit and are not added as presets.
