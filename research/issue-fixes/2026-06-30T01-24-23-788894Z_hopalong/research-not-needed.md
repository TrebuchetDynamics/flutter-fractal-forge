# Hopalong low-detail issue

External research was not needed. The issue targets local shader detail for the Hopalong Attractor issue view.

Fix evidence:

- `shaders/strange_attractors/hopalong_gpu.frag` now tracks an orbit-trap strand signal through the Hopalong recurrence.
- Both bounded and escaped color paths use that signal for palette separation and brightness detail.
- `test/modules/hopalong_detail_test.dart` locks the strand signal and compiles the shader.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/hopalong_detail_test.dart
git diff --check
```

Result: pass.
