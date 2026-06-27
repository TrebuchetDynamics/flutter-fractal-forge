# Orbit Trap: Heart Curve low deep zoom

External research not needed. This is local shader behavior at the supplied params.

Local evidence:
- `f1163_orbit_trap_heart_curve` uses `mandelbrot_orbit_trap_gpu.frag` with `trapMode=8`.
- The renderer scales GPU iterations upward at deep zoom, but this shader still capped `uIterations` at 500.
- At the reported zoom, a 500-iteration base scales above 500, so the shader was under-iterating the deep orbit-trap view.
- Raised the shader cap to the renderer policy ceiling.
