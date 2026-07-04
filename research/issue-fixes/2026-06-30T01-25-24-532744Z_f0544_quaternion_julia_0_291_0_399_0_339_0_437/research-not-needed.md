# Quaternion Julia randomize bad-results issue

External research was not needed. The issue came from random/share parameters with quaternion constants outside the stable range for the reviewed catalog entries.

Fix evidence:

- `lib/core/modules/builders/shared_catalogs/shared_quaternion_julia_catalog.dart` now constrains randomizable `c0`-`c3` parameters to `[-0.95, 0.95]` and clamps incoming values before sending shader uniforms.
- This prevents randomize/share values like `c0=-1.225`, `c1=-1.047` from driving the shared Quaternion Julia shader into bad/noisy results.
- `test/features/catalog/shared_quaternion_julia_randomize_bounds_test.dart` locks the randomizable bounds; existing shared catalog registration remains covered.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/features/catalog/shared_quaternion_julia_catalog_test.dart test/features/catalog/shared_quaternion_julia_randomize_bounds_test.dart
git diff --check
```

Result: pass.
