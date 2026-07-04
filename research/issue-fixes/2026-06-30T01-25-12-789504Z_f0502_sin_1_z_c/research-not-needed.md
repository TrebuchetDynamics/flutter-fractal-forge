# sin(1/z)+c low deep-zoom issue

External research was not needed. The issue uses `iterations=500`, but the shared sine escape-expression shader capped iterations at 120 and rendered bounded points as black.

Fix evidence:

- `shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag` now matches the 500-iteration deep-zoom issue setting.
- Bounded points now render with singularity trap coloring instead of a flat black fill, preserving detail around `sin(1/z)+c` deep zooms.
- `test/modules/sine_escape_deep_zoom_test.dart` locks the cap and bounded-color behavior.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/sine_escape_deep_zoom_test.dart
git diff --check
```

Result: pass. A shader-asset compile check was attempted first, but Flutter crashed while writing unrelated bundled shader outputs under `build/unit_test_assets`; the focused source regression test passed.
