# Bifurcation Diagram Explorer low-detail issue

External research was not needed. The issue targets local line visibility in the bifurcation diagram shader at the supplied sine-map view.

Fix evidence:

- `shaders/lyapunov_and_stability/bifurcation_diagram_gpu.frag` now derives a nearest-orbit ridge signal from the closest plotted orbit sample.
- The ridge signal adds color/detail and alpha support, improving low-detail and deep-zoom visibility without changing the map recurrence.
- `test/modules/bifurcation_diagram_detail_test.dart` locks the ridge-detail signal.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/bifurcation_diagram_detail_test.dart
git diff --check
```

Result: pass.
