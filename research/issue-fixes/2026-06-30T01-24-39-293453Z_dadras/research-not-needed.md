# Dadras low-detail issue

External research was not needed. The issue targets local shader detail for Dadras Attractor at the supplied view.

Fix evidence:

- `shaders/strange_attractors/dadras_gpu.frag` now tracks a derivative-based strand trap through the Dadras flow.
- Both bounded and escaped color paths use the strand signal for palette separation and brightness detail.
- `test/modules/dadras_detail_test.dart` locks the detail signal and compiles the shader.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/dadras_detail_test.dart
git diff --check
```

Result: pass.
