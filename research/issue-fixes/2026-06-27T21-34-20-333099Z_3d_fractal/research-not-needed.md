# 3D Fractal does not look correct

External research not needed. This is local shader behavior at the supplied params.

Local evidence:
- `3d_fractal_gpu.frag` is a 2D pseudo-3D escape map (`|z|²·z+c`), not a raymarched 3D surface.
- At the reported view, most sampled pixels remain bounded through 372 iterations.
- The old bounded branch rendered those pixels flat black, so the pseudo-3D map looked mostly missing/incorrect.
- Added interior orbit-trap coloring for bounded pixels without changing the map formula.
