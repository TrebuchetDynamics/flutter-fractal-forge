# Research not needed

Issue: `issues/2026-06-27T01-16-51-166237Z_f0352_clifford_coral.json`

This is a local renderer/default-detail issue:

- The issue reports low detail for `f0352_clifford_coral` at the shared coefficient-attractor default of `iterations=220`.
- Shared coefficient attractors render visible density by iterating the map per pixel; raising the default iteration count gives the density pass more samples without changing shader math or public coefficients.

Acceptance signal: focused shared Clifford catalog test verifies Clifford Coral now starts with a higher default iteration count while keeping its coefficients.
