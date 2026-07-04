# Fractal Flame V21 Rings low-detail issue

External research was not needed. The issue uses `iterations=140`, but the shared Fractal Flame shader capped density accumulation at 64 iterations.

Fix evidence:

- `shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag` now caps at the catalog max of 200 iterations.
- This lets V21 Rings honor the issue/share iteration setting instead of truncating density too early.
- `test/modules/fractal_flame_iteration_cap_test.dart` locks the cap and compiles the shader.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/fractal_flame_iteration_cap_test.dart
git diff --check
```

Result: pass.
