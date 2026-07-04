# sech(z)+c no-image issue

External research was not needed. The issue targets a local shared tanh/sech shader path where bounded points rendered as flat black.

Fix evidence:

- `shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag` now accumulates orbit/trap detail for tanh/sech variants.
- Bounded points render with sech trap coloring instead of a black fill, making the default `sech(z)+c` issue view visible.
- `test/modules/sech_visibility_test.dart` locks the bounded-color behavior.

Validation:

```sh
find shaders -type d -exec mkdir -p build/unit_test_assets/{} \;
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/sech_visibility_test.dart
git diff --check
```

Result: pass. The directory precreate avoids a Flutter shader-bundle write crash seen after clearing `build/unit_test_assets`.
