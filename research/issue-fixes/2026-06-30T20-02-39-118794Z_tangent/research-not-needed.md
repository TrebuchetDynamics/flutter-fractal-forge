# Tangent incorrect-fractal issue

External research was not needed. The issue targets the local Tangent shader near the tan pole region (`x≈3`), where the pole structure was not visibly emphasized.

Fix evidence:

- `shaders/trigonometric_and_transcendental/elementary_trig/tangent_gpu.frag` now tracks distance to tangent poles via `ccos(z)` during iteration.
- Bounded and escaped color paths use the pole signal, making the expected tangent pole bands/tendrils visible at the issue view.
- `test/modules/tangent_pole_detail_test.dart` locks the pole-detail signal.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/tangent_pole_detail_test.dart
git diff --check
```

Result: pass. One earlier identical test attempt hit Flutter's intermittent shader-bundle write crash; rerunning passed.
