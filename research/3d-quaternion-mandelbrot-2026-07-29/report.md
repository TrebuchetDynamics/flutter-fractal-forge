# Targeted research: Quaternion Mandelbrot 3D slice

## Scope

This follow-up starts from the audited 24-identity catalog and asks whether parameter-space quaternion dynamics are missing from the existing Julia-heavy hypercomplex coverage. Six targeted ResearchForge queries across OpenAlex, Crossref, and arXiv returned 305 records (81/104/120 by source) and 174 unique DOIs.

## Accepted identity

The quaternion Mandelbrot set uses the parameter-space recurrence

`q₀ = 0`, `qₙ₊₁ = qₙ² + c`,

and contains quaternion parameters `c` whose critical orbit remains bounded. The renderer takes the explicit 3D hyperplane `c=(x,y,z,0)` through the four-dimensional parameter set.

Evidence:

- Gomatam and Doyle describe `Q → Q² + C` as a natural quaternionic generalization of the Mandelbrot set to higher dimensions ([DOI 10.1016/0960-0779(94)00163-K](https://doi.org/10.1016/0960-0779(94)00163-K)).
- *3D Rendering of the Quaternion Mandelbrot Set with Memory* treats the quaternion Mandelbrot geometry as four-dimensional and describes cutting-plane dimensional reduction to 3D or 2D ([DOI 10.1142/S0218348X24500610](https://doi.org/10.1142/S0218348X24500610)). The catalog implementation uses the memory-free base recurrence, not the paper's memory variants.
- Knill defines Mandelstuff in a ring by the bounded orbit of zero under `z^d+c`, explicitly including the quaternionic Mandelbrot set for the escape ball in `H` ([arXiv:2305.17848](https://arxiv.org/abs/2305.17848)).

## Identity decision

`quaternion_mandelbrot_3d` is distinct from `quaternion_julia_3d`:

- Mandelbrot parameter space starts at `q₀=0` and varies `c` per sampled point.
- Julia dynamical space starts at the sampled point and keeps `c` fixed.

It is also not a fixed power or camera preset. The chosen `w=0` hyperplane is one stable 3D visualization contract for the 4D set. The quadratic quaternion set has rotational symmetry around its scalar axis, but its three-dimensional parameter subset and renderer are not the existing planar Mandelbrot module.

## Implementation decision

- Add one stable ID and one local shader using the quadratic recurrence only.
- Do not add powers, memory functions, or slice offsets as separate entries.
- Hide the irrelevant generic power control.
- Validate origin and `c=-1` as bounded and far real `c=2` as escaping in an independent CPU quaternion oracle.
- Use the scalar magnitude derivative recurrence only as the ray-marching distance estimate; do not claim it is an exact Euclidean distance.

## Claim hygiene and limits

No third-party shader code was copied. Metadata and abstracts establish the recurrence and slicing practice; no copyrighted full text was downloaded. The catalog name means the explicit 3D hyperplane slice, not the complete four-dimensional set. Memory-based quaternion Mandelbrot variants remain out of scope because changing history dependence would require separate provenance and validation.
