# Pseudo-Kleinian low-detail/no-image issue

External research was not needed. The issue targets the local `pseudo_kleinian` shader at the default view.

Fix evidence:

- `shaders/ifs_and_geometric/pseudo_kleinian_gpu.frag` now tracks fold-trap linework during the Kleinian fold loop.
- Both inside and escaped color paths mix that linework into palette phase and highlight contrast, preventing a flat/no-image default view.
- `test/modules/pseudo_kleinian_visibility_test.dart` locks the linework signal and compiles the shader asset.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/pseudo_kleinian_visibility_test.dart
git diff --check
```

Result: pass.
