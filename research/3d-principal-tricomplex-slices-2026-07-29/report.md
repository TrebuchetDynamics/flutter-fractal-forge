# Principal tricomplex 3D slices: Arrowheadbrot follow-up

## Method and limits

A comprehensive 27-query sweep covered the eight named principal three-dimensional slices of the quadratic tricomplex Mandelbrot set, their algebraic bases, idempotent decompositions, classification, and distance estimation. OpenAlex and arXiv returned 225 records (105 deduplicated by ResearchForge, 47 unique DOIs); Crossref returned 250 records (132 deduplicated). Across both saved libraries there are 475 records, 174 unique DOIs, and 219 unique normalized titles.

The first `--sources all` batch timed out without writing results. The reproducible rerun was split into OpenAlex/arXiv and Crossref. Eight late arXiv queries were rate-limited, but every query completed through OpenAlex and Crossref, and the defining papers were retrieved through both metadata and public open HTML. Citation expansion was attempted for three seeds: 25 edges for DOI `10.3390/math10030482`, 0 for `10.1007/s00006-019-0956-1`, and 12 for `10.1142/S0218127405013873`.

No PDF, TeX source, or third-party rendering code is stored in the repository. Public arXiv/ar5iv pages were inspected only to recover the displayed equations.

## Bottom line

The classical quadratic **Arrowheadbrot** is sufficiently specified for a defensible catalog identity. Vallières and Rochon define it as the principal slice `T(1,i₁,j₁)`, with `j₁=i₁i₂`; for `c=x+y i₁+z j₁`, membership is exactly the conjunction of ordinary complex Mandelbrot membership for `(x-z)+yi` and `(x+z)+yi`.

This is not a camera transform or parameter preset of the existing Tetrabrot. The Tetrabrot couples the third coordinate to the imaginary component, `x+(y±z)i`; the Arrowheadbrot couples it to the real component, `(x±z)+yi`, and the complex Mandelbrot set is not invariant under the coordinate exchange needed to identify those sections.

## Evidence and exact rule

### Named slice

Vallières and Rochon, *Relationship between the Mandelbrot Algorithm and the Platonic Solids* (Mathematics, 2022), Proposition 3, gives:

- name: Arrowheadbrot;
- basis: `T(1,i₁,j₁)`;
- coordinates: `c=c₁+c₂i₁+c₄j₁`;
- idempotent decomposition: `(d+c₄)γ₁+(d-c₄)γ̄₁`, where `d=c₁+c₂i₁`;
- membership: `d+c₄ ∈ M₁` and `d-c₄ ∈ M₁`;
- section characterization: `⋃[-9/8,9/8] {[(M₁-y) ∩ (M₁+y)] + yj₁}`.

Source: [arXiv:2107.04016](https://arxiv.org/abs/2107.04016), [DOI 10.3390/math10030482](https://doi.org/10.3390/math10030482).

### Why tricomplex space is sufficient

Brouillette and Rochon, *Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set* (Advances in Applied Clifford Algebras, 2019), proves that multicomplex Multibrot membership decomposes componentwise under orthogonal idempotents and that every multicomplex principal 3D slice is equivalent to a tricomplex slice up to affine transformation. For `p=2`, it identifies eight tricomplex equivalence classes, including Tetrabrot and Arrowheadbrot.

The same theorem gives the Euclidean idempotent norm

`||η|| = sqrt((||ηγ||² + ||ηγ̄||²)/2)`,

which supports combining component distance estimates by root-mean-square.

Source: [arXiv:1809.02020](https://arxiv.org/abs/1809.02020), [DOI 10.1007/s00006-019-0956-1](https://doi.org/10.1007/s00006-019-0956-1).

### Distance-estimator precedent

Martineau and Rochon, *On a Bicomplex Distance Estimation for the Tetrabrot* (International Journal of Bifurcation and Chaos, 2005), develops bicomplex component distance estimation for ray-traced principal slices. The Arrowheadbrot renderer uses the same ordinary complex quadratic estimator on its own published components, then applies the idempotent Euclidean norm above.

Source: [DOI 10.1142/S0218127405013873](https://doi.org/10.1142/S0218127405013873).

## Identity decision

Accepted stable ID: `arrowheadbrot_3d`.

It is distinct from:

- `tetrabrot_3d`: imaginary-axis versus real-axis component coupling;
- planar Mandelbrot: a conjunction of two coupled complex parameters over three real coordinates;
- quaternion Mandelbrot: commutative tricomplex idempotents versus noncommutative quaternion multiplication;
- higher Multibrot degrees: the accepted identity is fixed at the classical quadratic recurrence.

Independent CPU checks deliberately include two points that separate Arrowheadbrot and Tetrabrot:

- `(-7/8,0,9/8)` maps to complex endpoints `-2` and `1/4`, so it belongs to Arrowheadbrot but not Tetrabrot;
- `(0,0,0.3)` maps to real parameters `-0.3` and `0.3`, so it is outside Arrowheadbrot, while the corresponding Tetrabrot parameters `±0.3i` remain bounded at the oracle depth.

## Other candidates

Mousebrot, Turtlebrot, Hourglassbrot, Metabrot, Airbrot, and Firebrot remain named, mathematically meaningful candidates. They are not aliases of Arrowheadbrot and were not bundled as presets. This cycle does not add them because each deserves its own exact basis-to-component derivation and render/oracle review.

Firebrot and Airbrot need additional product-level scrutiny: the quadratic Firebrot is a regular tetrahedron and Airbrot an octahedron, so their dynamical provenance alone may not justify presenting them as visually fractal catalog entries.

## Claim hygiene and evidence gaps

- The shader output is a conservative ray-marching estimator, not a proof of exact signed Euclidean distance to the boundary.
- Finite-iteration CPU membership is exact for the selected real endpoint/fixed-orbit cases and a stable bounded check for `±0.3i`; it is not a general decidability result.
- Search metadata establishes provenance and discovery coverage; mathematical claims above are tied to displayed equations in the named open papers, not inferred from search ranking.
- Eight arXiv requests were rate-limited and Ketch web search was rate-limited; OpenAlex/Crossref coverage and direct public-page inspection filled the targeted evidence need.

## Implementation implication

Implement one fixed-degree module with two complex components `(x-z,y)` and `(x+z,y)`, root-mean-square component distance, hidden generic power control, standard 3D camera/uniform layout, formula-contract tests, independent membership comparisons against Tetrabrot, runtime shader compilation, and strict GPU image-health auditing.
