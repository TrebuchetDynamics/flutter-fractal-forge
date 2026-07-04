# Klausmeier Vegetation low-detail issue

External research was not needed. The issue points to a local visual-detail regression in the existing Klausmeier shader at the shared view:

- module: `klausmeier_vegetation`
- view: `z=0.018779301494684427`, `x=-3`, `y=-1.8033372163772583`
- params: default Klausmeier controls from the issue JSON

Fix evidence:

- `shaders/cellular_and_stochastic/klausmeier_vegetation_gpu.frag` now uses multi-scale terrain bands and stronger ridge contrast instead of the prior single broad terrain wave.
- `lib/features/renderer/cpu/academic_expansion_formula_helpers.dart` mirrors the visual-detail signal in the CPU fallback formula.
- `test/modules/klausmeier_vegetation_detail_test.dart` renders the issue view and asserts luminance variance plus horizontal neighbor detail.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/klausmeier_vegetation_detail_test.dart
```

Result: pass.
