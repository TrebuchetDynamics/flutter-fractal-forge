# Svensson Halo low-detail/no-image issue

External research was not needed. The issue uses `iterations=360`, but the shared Svensson shader capped execution at 160 iterations.

Fix evidence:

- `shaders/strange_attractors/svensson_gpu.frag` now allows up to 500 iterations, matching the shared attractor catalog parameter range.
- This lets `f1054_svensson_halo` honor its high-detail issue/share settings instead of silently truncating the orbit accumulation.
- `test/modules/svensson_iteration_cap_test.dart` locks the shader cap and compiles the shader.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/svensson_iteration_cap_test.dart
git diff --check
```

Result: pass.
