# Magnet Type II low deep-zoom issue

External research was not needed. The issue targets a deep-zoom view where bounded points in the local Magnet Type II shader rendered as flat black.

Fix evidence:

- `shaders/escape_time_family/newton_and_orthogonal/magnet_maps/magnet2_gpu.frag` now accumulates orbit/trap detail through the Magnet Type II iteration.
- Bounded deep-zoom basins render with trap coloring instead of a black fill.
- `test/modules/magnet_type_2_deep_zoom_test.dart` locks the bounded-color behavior.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/magnet_type_2_deep_zoom_test.dart
git diff --check
```

Result: pass.
