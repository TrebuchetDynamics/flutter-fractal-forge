# Life-like B0/S0 no-image issue

External research was not needed. The local Life-like shader interpreted small catalog masks only as bitfields, so `birthMask=0`/`survivalMask=0` meant no birth or survival counts instead of the catalog label's B0/S0 rule.

Fix evidence:

- `shaders/cellular_and_stochastic/maze_ca_gpu.frag` now treats masks `0..8` as explicit neighbor counts, while larger values still use bitmask semantics.
- This makes `life_like_b000_s000` render the B0/S0 rule named by the module instead of a blank empty-rule image.
- `test/modules/life_like_b0_s0_visibility_test.dart` locks the mask interpretation.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/life_like_b0_s0_visibility_test.dart
git diff --check
```

Result: pass. One earlier retry hit Flutter's intermittent shader-bundle write crash; rerunning the same focused test passed.
