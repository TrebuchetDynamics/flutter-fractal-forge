# Multibrot d=8.5 low deep zoom

External research not needed. This is local shader behavior at the supplied params.

Local evidence:
- `f0102_multibrot_d_8_5` uses `multibrot3_gpu.frag` with `uPower=8.5`.
- The issue requests 940 iterations, but the shader capped `uIterations` at 500.
- The reported deep view has bounded pixels at 940 iterations; the old interior branch rendered those pixels flat black.
- Raised the shader iteration cap to the renderer policy ceiling and added interior orbit-trap coloring for bounded pixels.
