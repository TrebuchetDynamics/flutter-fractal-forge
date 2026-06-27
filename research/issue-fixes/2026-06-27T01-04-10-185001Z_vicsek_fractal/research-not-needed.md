# Research not needed

Issue: `issues/2026-06-27T01-04-10-185001Z_vicsek_fractal.json`

This is a local shader detail bug, not a domain uncertainty:

- The issue reports Vicsek Fractal does not look correct at zoom about 42 with `iterations=404`.
- `vicsek_gpu.frag` mapped iterations to recursive depth but clamped depth to 12 and used a 12-level static loop, so high-iteration/deeper views could not add structure.

Acceptance signal: a focused shader source regression test verifies the Vicsek shader can use deeper recursive levels.
