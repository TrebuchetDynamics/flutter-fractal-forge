# Rule 150 Linear CA incorrect-fractal issue

External research was not needed. The local shader was approximating Rule 150 as neighboring Rule 90 rows, which is not the single-seed Rule 150 recurrence.

Fix evidence:

- `shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag` now uses a Rule 150 trinomial-parity evaluator for the 256-row catalog/issue view.
- The previous `rule90State(gen, cell - 1) + rule90State(gen, cell) + rule90State(gen, cell + 1)` shortcut was removed.
- The shader still compiles through the existing CA shader asset test, and `test/academic_expansion_linear_ca_test.dart` keeps the CPU Rule 150 recurrence covered.

Validation:

```sh
find shaders -type d -exec mkdir -p build/unit_test_assets/{} \;
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/rule150_shader_contract_test.dart test/modules/rule90_detail_test.dart test/academic_expansion_linear_ca_test.dart
git diff --check
```

Result: pass.
