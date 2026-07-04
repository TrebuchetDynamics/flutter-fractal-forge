# Householder low-detail issue

External research was not needed. The issue targets local coloring detail in the Householder root-basin shader.

Fix evidence:

- `shaders/root_finding/householder_gpu.frag` now computes nearest/second-nearest root distances and derives a basin-boundary signal.
- The final palette phase and brightness use that boundary signal so the default issue view shows basin detail instead of broad flat regions.
- `test/modules/householder_detail_test.dart` locks the boundary-detail signal.

Validation:

```sh
find shaders -type d -exec mkdir -p build/unit_test_assets/{} \;
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/householder_detail_test.dart
git diff --check
```

Result: pass.
