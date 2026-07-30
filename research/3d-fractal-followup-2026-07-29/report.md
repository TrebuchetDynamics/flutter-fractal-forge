# Targeted 3D fractal follow-up: Cantor Dust 3D

## Scope

This follow-up starts from the completed 23-identity 3D audit and searches only for another mathematically explicit transform system. Eight targeted queries covered three-dimensional Cantor products and regular-polyhedron IFS candidates across OpenAlex, Crossref, and arXiv. ResearchForge returned 429 records (OpenAlex 109, Crossref 160, arXiv 160) and 259 unique DOIs.

## Accepted identity: Cantor Dust 3D

Let `C` be the middle-thirds Cantor set. The accepted object is the Cartesian product

`C³ = C × C × C`.

The product of the two standard similarities for each coordinate yields exactly eight corner maps. Each map has contraction ratio `1/3`, so the similarity dimension `d` satisfies

`8 * (1/3)^d = 1`, hence `d = log(8) / log(3) = 3 log(2) / log(3)`.

Evidence:

- *Hausdorff measure of cartesian product of Cantor sets* studies the `d`-fold Cartesian product of the middle-thirds Cantor set and states its dimension as `d log₃ 2`; specialize to ambient/product dimension three ([arXiv:2510.09701](https://arxiv.org/abs/2510.09701)).
- *Hausdorff Measure of Cartesian Product of the Ternary Cantor Set* establishes the corresponding `C × C` product construction ([DOI 10.1142/S0218348X12500077](https://doi.org/10.1142/S0218348X12500077)).

Implementation decision: add one stable `cantor_dust_3d` identity with eight fixed corner similarities at scale `1/3`. Iteration depth is a rendering approximation control, not a separate catalog identity. It is distinct from the existing planar `cantor_dust` (`C²`) because its attractor and ambient dimension are different.

## Rejected candidates

The targeted search also returned metadata for fractal polyhedra, including *Connectivity calculus of fractal polyhedrons* ([DOI 10.1016/j.patcog.2014.05.016](https://doi.org/10.1016/j.patcog.2014.05.016)). It did not expose exact contraction systems for named Sierpinski icosahedron or dodecahedron candidates in the retrieved metadata. Those candidates remain rejected rather than introducing visually plausible but mathematically under-specified variants.

## Claim hygiene

- “Cantor Dust 3D” is used as a catalog-facing name for the explicit set `C³`; no historical naming-priority claim is made.
- The renderer uses a finite iteration depth, while the mathematical identity is the limiting eight-map IFS.
- No third-party renderer or shader code was copied.
- Metadata/abstract evidence was sufficient for the product and dimension claim; no copyrighted full text was downloaded.
