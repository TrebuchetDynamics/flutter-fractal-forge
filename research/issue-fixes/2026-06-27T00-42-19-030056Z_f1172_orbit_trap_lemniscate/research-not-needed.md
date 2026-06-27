# Research not needed

Issue: `issues/2026-06-27T00-42-19-030056Z_f1172_orbit_trap_lemniscate.json`

This is a local shader-asset wiring bug, not a domain/math uncertainty:

- The issue tags `f1172_orbit_trap_lemniscate` as `NO shader`.
- The generated module points at `shaders/f1172_orbit_trap_lemniscate_gpu.frag`, which does not exist.
- The reviewed shared orbit-trap shader exists at `shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag` and implements `mode == 17` for Lemniscate.
- `pubspec.yaml` already declares the shared shader asset.

Acceptance signal: a focused Flutter test verifies F1172 resolves to the existing, declared shared shader asset with trap mode 17 support.
