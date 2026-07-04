# Buddhabrot low deep-zoom issue

External research was not needed. The issue targets a deep-zoom view where bounded points in the local Buddhabrot approximation rendered as flat black.

Fix evidence:

- `shaders/escape_time_family/families/buddhabrot/buddhabrot_gpu.frag` now accumulates orbit/trap detail during the Mandelbrot orbit.
- Bounded deep-zoom points render with interior trap coloring instead of a black fill.
- `test/modules/buddhabrot_deep_zoom_test.dart` locks the bounded-color behavior.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/buddhabrot_deep_zoom_test.dart
git diff --check
```

Result: pass. One earlier attempt hit Flutter's intermittent shader-bundle write crash; rerunning passed.
