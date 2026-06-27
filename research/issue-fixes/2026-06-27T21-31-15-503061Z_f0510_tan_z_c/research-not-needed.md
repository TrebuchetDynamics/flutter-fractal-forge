# tan(z²)+c low deep zoom

External research not needed. This is local shader behavior at the supplied params.

Local evidence:
- `f0510_tan_z_c` uses `tangent_mandelbrot_gpu.frag` with `variant=1`.
- The renderer scales GPU iterations for deep zooms, but this shader capped them at 500.
- The reported view contains many pixels still bounded at 500 iterations; the old interior branch rendered those pixels flat black.
- Raised the shader cap to the renderer policy ceiling and added simple interior orbit-trap coloring for bounded pixels.
