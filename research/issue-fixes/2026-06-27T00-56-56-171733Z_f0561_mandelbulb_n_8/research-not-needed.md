# Research not needed

Issue: `issues/2026-06-27T00-56-56-171733Z_f0561_mandelbulb_n_8.json`

This is a local shader fidelity bug, not a domain uncertainty:

- The issue reports low deep zoom for `f0561_mandelbulb_n_8` with `iterations=50`, `steps=120`, and zoom about 3.3.
- The shared Mandelbulb shader accepted UI iteration values above 20 but internally clamped `uIterations` to 20 and used a 20-iteration static loop.
- The same shader exposed steps up to 200 in Dart but internally clamped ray-march steps to 150.

Acceptance signal: a focused shader source regression test verifies the shader honors higher iteration and step caps instead of silently truncating the reported settings.
