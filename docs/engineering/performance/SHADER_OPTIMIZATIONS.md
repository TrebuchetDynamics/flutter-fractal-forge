# Shader Source and Optimization Notes

This document records current shader structure and evidence limits. It does not claim that every shader uses the same optimization or meets a fixed frame rate.

## Asset and uniform ownership

Flutter shader assets are declared under `flutter.shaders` in `pubspec.yaml`. The shader contribution workflow is in [`CONTRIBUTING.md`](../../../CONTRIBUTING.md).

Standard escape-time modules use the slot definitions in `lib/core/modules/builders/uniform_layout.dart` and the setter in `lib/core/modules/builders/escape_time/builder.dart`. Slots 0 through 9 hold the shared values. Extra parameters start at slot 10. The 3D and double-float layouts use different slots. Do not copy a uniform index between shader families without checking its matching builder.

## Coloring coverage

`test/shaders/smooth_coloring_family_coverage_test.dart` checks source-level smooth-coloring paths in ten bounded families (14 shaders):

| Family | Shader paths | Checked coloring form |
|---|---|---|
| Quadratic legacy | `shaders/legacy/escape_time/mandel_step_smooth.frag`, `shaders/legacy/escape_time/julia.frag`, `shaders/legacy/escape_time/burning_ship.frag` | Quadratic `log2(log2(|z|²))` correction; palette coordinate uses the smoothed iteration |
| Quadratic perturbation | `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` | Quadratic correction from saved escaped `finalMag2` |
| Integer-power polynomial | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag`, `shaders/escape_time_family/polynomial_maps/druid_gpu.frag` | Degree-aware correction using the configured power or degree 3 |
| Rational escape map | `shaders/escape_time_family/geometry_and_ifs/mcmullen_map_gpu.frag` | Degree-aware correction using its `nf` parameter |
| Quadratic Buffalo | `shaders/escape_time_family/families/buffalo/buffalo_gpu.frag` | Quadratic `log2(log2(|z|²))` correction |
| Cubic Buffalo | `shaders/escape_time_family/families/buffalo/buffalo_cubic_gpu.frag` | Cubic correction divides `log2(log2(|z|²))` by `log2(3)` |
| Transcendental map | `shaders/escape_time_family/transcendental_maps/collatz_gpu.frag` | Escape-iteration correction `it - log2(log2(|z|²))`; palette coordinate uses the smoothed iteration |
| Feather map | `shaders/escape_time_family/julia_variants/feather_gpu.frag`, `shaders/escape_time_family/julia_variants/feather_julia_gpu.frag` | Degree-3 correction; both standard and normal-map palette coordinates use the smoothed iteration |
| Shark Fin map | `shaders/escape_time_family/polynomial_maps/shark_fin_gpu.frag` | Quadratic correction; standard palette coordinate uses the smoothed iteration |
| Phoenix memory map | `shaders/escape_time_family/core/phoenix_gpu.frag` | Memory-term quadratic recurrence; escaped magnitude correction feeds standard and normal-map palette coordinates |

The regression asserts each shader's expected formula, its use in the escaped-pixel palette coordinate, and distinct inside-set output. This is bounded source coverage, not a full inventory of all escape-time shaders, a GPU rendering check, or proof of visual banding reduction. Other shader families and unlisted shaders remain outside this test; P1-3 remains open for a complete audit.

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
