# Research not needed

Issue: `issues/2026-06-27T00-42-52-830168Z_life_like_b014_s000.json`

This is local shader-asset verification, not a domain/math uncertainty:

- The issue tags `life_like_b014_s000` as `NO shader`.
- `shared_life_like_catalog.dart` generates this Life-like rule and uses `shaders/cellular_and_stochastic/maze_ca_gpu.frag`.
- The shader file exists and is declared in `pubspec.yaml`.

Acceptance signal: focused shared Life-like catalog test verifies the generated Life-like catalog shader wiring.
