# Dual-Complex low deep-zoom issue

External research was not needed. The issue targets a deep-zoom view where bounded points in the local Dual-Complex shader rendered as flat black.

Fix evidence:

- `shaders/3d_and_hypercomplex/hypercomplex_escape_time/dual_complex_gpu.frag` now accumulates orbit/trap detail during iteration.
- Bounded points render with dual-number trap coloring instead of a black fill, preserving detail for the issue deep zoom.
- `test/modules/dual_complex_deep_zoom_test.dart` locks the bounded-color behavior.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/dual_complex_deep_zoom_test.dart
git diff --check
```

Result: pass.
