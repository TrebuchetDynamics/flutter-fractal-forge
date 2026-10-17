# Shader Source and Optimization Notes

This document records current shader structure and evidence limits. It does not claim that every shader uses the same optimization or meets a fixed frame rate.

## Asset and uniform ownership

Flutter shader assets are declared under `flutter.shaders` in `pubspec.yaml`. The shader contribution workflow is in [`CONTRIBUTING.md`](../../../CONTRIBUTING.md).

Standard escape-time modules use the slot definitions in `lib/core/modules/builders/uniform_layout.dart` and the setter in `lib/core/modules/builders/escape_time/builder.dart`. Slots 0 through 9 hold shared values. Extra parameters start at slot 10. Ray-marched 3D modules share a frame/camera prefix through `setRaymarched3DFrameUniforms()`: time at slot 0, resolution at 1–2, pan target (`uMousePos`) at 3–4, zoom at 5, and rotation at 6–8. Module-specific 3D parameters follow that prefix. Mandelbrot double-float has its own layout. Do not reuse an index across shader families without checking its matching builder and shader declarations.

## Coloring coverage

`test/shaders/smooth_coloring_family_coverage_test.dart` checks source-level smooth-coloring paths in ten bounded families (15 shaders):

| Family | Shader paths | Checked coloring form |
|---|---|---|
| Quadratic legacy | `shaders/legacy/escape_time/mandel_step_smooth.frag`, `shaders/legacy/escape_time/julia.frag`, `shaders/legacy/escape_time/burning_ship.frag` | Quadratic `log2(log2(|z|²))` correction; palette coordinate uses the smoothed iteration |
| Quadratic perturbation | `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` | Quadratic correction from saved escaped `finalMag2` |
| Integer-power polynomial | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag`, `shaders/escape_time_family/families/multibrot/integer_powers/multibrot4_gpu.frag`, `shaders/escape_time_family/polynomial_maps/druid_gpu.frag` | Degree-aware correction using the configured power, degree 4, or degree 3 |
| Rational escape map | `shaders/escape_time_family/geometry_and_ifs/mcmullen_map_gpu.frag` | Degree-aware correction using its `nf` parameter |
| Quadratic Buffalo | `shaders/escape_time_family/families/buffalo/buffalo_gpu.frag` | Quadratic `log2(log2(|z|²))` correction |
| Cubic Buffalo | `shaders/escape_time_family/families/buffalo/buffalo_cubic_gpu.frag` | Cubic correction divides `log2(log2(|z|²))` by `log2(3)` |
| Transcendental map | `shaders/escape_time_family/transcendental_maps/collatz_gpu.frag` | Escape-iteration correction `it - log2(log2(|z|²))`; palette coordinate uses the smoothed iteration |
| Feather map | `shaders/escape_time_family/julia_variants/feather_gpu.frag`, `shaders/escape_time_family/julia_variants/feather_julia_gpu.frag` | Degree-3 correction; both standard and normal-map palette coordinates use the smoothed iteration |
| Shark Fin map | `shaders/escape_time_family/polynomial_maps/shark_fin_gpu.frag` | Quadratic correction; standard palette coordinate uses the smoothed iteration |
| Phoenix memory map | `shaders/escape_time_family/core/phoenix_gpu.frag` | Memory-term quadratic recurrence; escaped magnitude correction feeds standard and normal-map palette coordinates |

The regression asserts each listed shader's expected formula, its use in the escaped-pixel palette coordinate, and distinct inside-set output. For the integer-power Multibrot family, the live catalog bindings and current smooth-coloring assertions reconcile as follows:

| Module | Live shader binding | Status in source regression tests |
|---|---|---|
| `multibrot3` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/core_escape_time_family.dart:338`) | Checked: degree-aware formula using `log(max(1.001, abs(power)))`, smoothed palette coordinate, and distinct inside-set path. |
| `multibrot4` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot4_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/cellular_stochastic.dart:708`) | Checked: degree-4 `log(4.0)` correction, smoothed palette coordinate, and distinct inside-set path. The existing power regression also checks its correction and early-out. |
| `multibrot5` | `shaders/escape_time_family/families/multibrot/multibrot5_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/cellular_stochastic.dart:725`) | Unverified by smooth-coloring assertions; source has degree-5 correction and uses it for palette coordinates. |
| `multibrot6` | `shaders/escape_time_family/families/multibrot/multibrot6_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/batch_14_extensions.dart:76`) | Unverified by smooth-coloring assertions; source has degree-6 correction and uses it for palette coordinates. |
| `multibrot7` | `shaders/escape_time_family/families/multibrot/multibrot7_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/batch_14_extensions.dart:256`) | Unverified by smooth-coloring assertions; source has degree-7 correction and uses it for palette coordinates. |
| `multibrot8` | `shaders/escape_time_family/families/multibrot/multibrot8_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/batch_14_extensions.dart:264`) | Unverified by smooth-coloring assertions; source has degree-8 correction and uses it for palette coordinates. |
| `multibrot9` | `shaders/escape_time_family/families/multibrot/multibrot9_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/batch_14_extensions.dart:531`) | Unverified by smooth-coloring assertions; source has degree-9 correction and uses it for palette coordinates. |
| `multibrot10` | `shaders/escape_time_family/families/multibrot/multibrot10_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/batch_14_extensions.dart:548`) | Unverified by smooth-coloring assertions; source has degree-10 correction and uses it for palette coordinates. |
| `multibrot11` | `shaders/escape_time_family/families/multibrot/multibrot11_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/batch_14_extensions.dart:577`) | Unverified by smooth-coloring assertions; source has degree-11 correction and uses it for palette coordinates. |
| `multibrot12` | `shaders/escape_time_family/families/multibrot/multibrot12_gpu.frag` (`lib/core/modules/builders/escape_time_catalog/batch_14_extensions.dart:585`) | Unverified by smooth-coloring assertions; source has degree-12 correction and uses it for palette coordinates. |

“Checked” here means bounded source assertions only, not visual or hardware-GPU qualification. The integer-power inventory does not include the non-integer degree 1.5/2.5 variants or the negative-power map. Integer-power degrees 5–12 remain uncovered by the smooth-coloring regression; the other shader families and unlisted shaders also remain outside this bounded test, so P1-3 is still open for a complete audit.

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
