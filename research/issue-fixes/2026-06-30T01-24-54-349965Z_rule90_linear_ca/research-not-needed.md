# Rule 90 Linear CA low-detail issue

External research was not needed. The issue targets the local shared Wolfram CA shader at 256 rows.

Fix evidence:

- `shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag` now computes per-cell phase and row/cell edge detail for the Rule 90/150 exact paths.
- The color path uses that detail to keep individual CA cells legible at the issue view.
- `test/modules/rule90_detail_test.dart` locks the detail signal and compiles the shader; `test/academic_expansion_linear_ca_test.dart` keeps the Rule 90 formula contract covered.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/rule90_detail_test.dart test/academic_expansion_linear_ca_test.dart
git diff --check
```

Result: pass.
