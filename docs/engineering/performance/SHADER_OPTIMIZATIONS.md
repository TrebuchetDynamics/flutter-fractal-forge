# Shader Source and Optimization Notes

This document records current shader structure and evidence limits. It does not claim that every shader uses the same optimization or meets a fixed frame rate.

## Asset and uniform ownership

Flutter shader assets are declared under `flutter.shaders` in `pubspec.yaml`. The shader contribution workflow is in [`CONTRIBUTING.md`](../../../CONTRIBUTING.md).

Standard escape-time modules use the slot definitions in `lib/core/modules/builders/uniform_layout.dart` and the setter in `lib/core/modules/builders/escape_time/builder.dart`. Slots 0 through 9 hold the shared values. Extra parameters start at slot 10. The 3D and double-float layouts use different slots. Do not copy a uniform index between shader families without checking its matching builder.

## Coloring coverage

The smooth-iteration expression in `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` is one implementation. Other shaders use their own coloring code. The repository does not have a test that proves smooth coloring is present in every applicable polynomial escape-time shader. The coverage goal in `TODO.md` under P1-3 remains open.

Do not apply one coloring formula to every recurrence without checking its iteration and magnitude values. Shader families can require different formulas.

## Optimization evidence

Earlier versions of this document described global level-of-detail and branchless-palette optimizations, and included performance-improvement estimates. The current sources and retained test receipts do not support those statements as project-wide claims. This document does not report a controlled before/after shader performance result.

For source compatibility checks, run:

```bash
flutter test test/shaders/shader_web_compat_test.dart
flutter test test/modules/escape_time_shader_manifest_test.dart
```

For runtime behavior, use the device-specific checks in [`PERFORMANCE.md`](PERFORMANCE.md). For the broader Linux catalog audit and its limits, see [`LINUX_FRACTAL_AUDIT.md`](LINUX_FRACTAL_AUDIT.md).

A performance comparison must identify its device, GPU and driver, renderer, resolution, fractal, iteration or ray-step settings, and warm-up procedure. Compare runs made with the same settings. Do not report a software-rendered run as a hardware-GPU result.
