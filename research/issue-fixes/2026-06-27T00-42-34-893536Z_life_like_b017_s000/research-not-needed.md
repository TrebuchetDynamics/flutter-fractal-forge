# Research not needed

Issue: `issues/2026-06-27T00-42-34-893536Z_life_like_b017_s000.json`

This is local shader-asset verification, not a domain/math uncertainty:

- The issue tags `life_like_b017_s000` as `NO shader`.
- `shared_life_like_catalog.dart` registers this generated Life-like rule with `shaders/cellular_and_stochastic/maze_ca_gpu.frag`.
- The shader file exists and is declared in `pubspec.yaml`.

Acceptance signal: focused shared Life-like catalog test verifies the module, shader asset, and B17/S0 masks.
