# Sprott G low-detail issue

External research was not needed. The issue targets local shader detail for Sprott G at the supplied deep view.

Fix evidence:

- `shaders/strange_attractors/sprott_g_gpu.frag` now tracks a derivative-based strand trap during the Sprott G flow integration.
- The inside-attractor color path uses the strand signal to add palette phase separation and highlight contrast.
- `test/modules/sprott_g_detail_test.dart` locks the detail signal and compiles the shader asset.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/sprott_g_detail_test.dart
git diff --check
```

Result: pass.
