# Research not needed

Issue: `issues/2026-06-27T00-41-40-660473Z_f1175_orbit_trap_square_lattice.json`

This is a local shader-asset wiring bug, not a domain/math uncertainty:

- The issue tags `f1175_orbit_trap_square_lattice` as `NO shader`.
- The generated module points at `shaders/f1175_orbit_trap_square_lattice_gpu.frag`, which does not exist.
- The reviewed shared orbit-trap shader exists at `shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag` and implements `mode == 20` for Square Lattice.
- `pubspec.yaml` already declares the shared shader asset.

Acceptance signal: a focused Flutter test verifies F1175 resolves to the existing, declared shared shader asset with trap mode 20 support.
