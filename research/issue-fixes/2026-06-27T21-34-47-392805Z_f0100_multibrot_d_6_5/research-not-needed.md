# Multibrot d=6.5 low deep zoom

External research not needed. This is local shader behavior at the supplied params.

Local evidence:
- `f0100_multibrot_d_6_5` uses the shared parameterized Multibrot shader with `uPower=6.5`.
- The issue requests 964 iterations, while the old shader capped `uIterations` at 500.
- The reported deep view has many pixels needing more than 500 iterations or remaining bounded at 964.
- The shared Multibrot shader now honors up to the renderer policy ceiling and colors bounded interiors with orbit traps.
