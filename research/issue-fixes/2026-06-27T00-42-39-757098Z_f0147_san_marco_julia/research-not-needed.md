# Research not needed

Issue: `issues/2026-06-27T00-42-39-757098Z_f0147_san_marco_julia.json`

This is a local shader-asset wiring bug, not a domain/math uncertainty:

- The issue tags `f0147_san_marco_julia` as `NO shader`.
- The generated module points at `shaders/f0147_san_marco_julia_gpu.frag`, which does not exist.
- The reviewed shared Julia catalog registers this identity with `shaders/escape_time_family/core/julia_gpu.frag` and constants `juliaCReal=-0.75`, `juliaCImag=0.0`.
- `pubspec.yaml` declares the shared Julia shader.

Acceptance signal: focused Flutter tests verify the generated module and shared Julia catalog wiring.
