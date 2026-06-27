# Research not needed

Issue: `issues/2026-06-27T01-17-08-983615Z_f1099_lozi_strange.json`

This is a local shader bug:

- The issue reports `No image` for `f1099_lozi_strange` with bounded Lozi parameters.
- `lozi_gpu.frag` returned black when an orbit stayed bounded for all requested iterations (`it >= target`).
- For bounded strange-attractor maps, that branch is the expected visible attractor region, not a no-image state.

Acceptance signal: focused shader source test verifies the bounded branch colors from density instead of returning black.
