# Sprott C low-detail issue

External research was not needed. The issue targets local shader detail for `sprott_c` / Sprott Case C at the default view.

Fix evidence:

- `shaders/strange_attractors/sprott_c_gpu.frag` now tracks an orbit-trap strand signal during the Sprott C flow integration.
- The inside-attractor color path mixes that strand signal into palette phase and highlight contrast instead of using only broad orbit accumulation.
- `test/modules/sprott_c_detail_test.dart` locks the strand-detail signal and compiles the shader asset.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/sprott_c_detail_test.dart
git diff --check
```

Result: pass.
