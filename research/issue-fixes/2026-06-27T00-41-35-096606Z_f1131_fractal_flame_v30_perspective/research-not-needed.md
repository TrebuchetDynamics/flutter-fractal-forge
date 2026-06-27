# Research not needed

Issue: `issues/2026-06-27T00-41-35-096606Z_f1131_fractal_flame_v30_perspective.json`

This is a local asset-wiring bug, not a domain/math uncertainty:

- The issue tags `f1131_fractal_flame_v30_perspective` as `NO shader`.
- The legacy generated module points at `shaders/f1131_fractal_flame_v30_perspective_gpu.frag`, which does not exist.
- The reviewed shared fractal-flame shader exists at `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag` and implements `var_id == 30` as the Perspective variation.
- `pubspec.yaml` already declares the shared shader asset.

Acceptance signal: a focused Flutter test verifies the F1131 module resolves to an existing, declared shader asset.
