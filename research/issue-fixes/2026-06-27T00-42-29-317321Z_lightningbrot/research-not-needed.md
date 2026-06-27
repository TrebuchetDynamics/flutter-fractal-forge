# Research not needed

Issue: `issues/2026-06-27T00-42-29-317321Z_lightningbrot.json`

This is local shader-asset verification, not a domain/math uncertainty:

- The issue tags `lightningbrot` as `NO shader`.
- `escape_time_catalog.dart` registers `lightningbrot` with `shaders/escape_time_family/mandelbrot_variants/iterative_maps/lightningbrot_gpu.frag`.
- The shader file exists on disk and `pubspec.yaml` declares it.

Acceptance signal: focused shader asset catalog test verifies the asset is present and declared.
