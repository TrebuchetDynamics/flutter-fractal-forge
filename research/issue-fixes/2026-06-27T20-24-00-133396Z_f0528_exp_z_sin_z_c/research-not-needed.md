# exp(z)sin(z)+c low deep zoom

External research not needed. This is local shader behavior at the supplied share params.

Local evidence:
- `sine_mandelbrot_gpu.frag` returned flat black for non-escaped/interior pixels.
- The reported `f0528_exp_z_sin_z_c` module is variant 8, so a deep zoom inside a non-escaped region can look empty even at 500 iterations.
- Added variant-8-only interior orbit-trap coloring so deep interior views retain detail without changing other sine variants' interior behavior.
