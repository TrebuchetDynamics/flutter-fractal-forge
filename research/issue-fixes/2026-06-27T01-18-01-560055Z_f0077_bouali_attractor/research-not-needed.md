# Research not needed

Issue: `issues/2026-06-27T01-18-01-560055Z_f0077_bouali_attractor.json`

This is a local shader-detail bug:

- The issue reports low detail for Bouali Attractor at `iterations=360`.
- `bouali_gpu.frag` integrated the attractor with a very small fixed step (`dt=0.006`), so 360 iterations covered a short trajectory and produced weak orbit-density variation.
- Raising the local integration step increases visible trajectory development without changing uniforms or catalog identity.

Acceptance signal: focused shader source test verifies Bouali uses the updated integration step.
