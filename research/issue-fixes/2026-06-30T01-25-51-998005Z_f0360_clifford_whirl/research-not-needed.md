# Clifford Whirl low-detail/no-image issue

External research was not needed. The issue uses `iterations=360`, but the shared Clifford shader capped rendering at 160 iterations.

Fix evidence:

- `shaders/strange_attractors/clifford_gpu.frag` now allows up to 500 iterations, matching the shared coefficient-attractor catalog range.
- This lets `f0360_clifford_whirl` honor its high-detail issue/share settings instead of silently truncating density accumulation.
- `test/modules/clifford_iteration_cap_test.dart` locks the cap.

Validation:

```sh
find shaders -type d -exec mkdir -p build/unit_test_assets/{} \;
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/clifford_iteration_cap_test.dart
git diff --check
```

Result: pass.
