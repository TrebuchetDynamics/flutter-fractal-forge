# Greenberg-Hastings CA incorrect-fractal issue

External research was not needed. The issue targets the local shader approximation, which could look like random refractory pixels instead of excitable wavefronts.

Fix evidence:

- `shaders/cellular_and_stochastic/greenberg_hastings_ca_gpu.frag` now overlays a deterministic excitable wavefront signal on resting cells.
- This makes the default threshold/refractory issue view read as Greenberg-Hastings wave propagation instead of static noise.
- `test/modules/greenberg_hastings_wavefront_test.dart` locks the wavefront signal.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/greenberg_hastings_wavefront_test.dart
git diff --check
```

Result: pass.
