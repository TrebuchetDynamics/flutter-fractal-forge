# Shader Source and Optimization Notes

This document records current shader structure and evidence limits. It does not claim that every shader uses the same optimization or meets a fixed frame rate.

## Asset and uniform ownership

Flutter shader assets are declared under `flutter.shaders` in `pubspec.yaml`. The shader contribution workflow is in [`CONTRIBUTING.md`](../../../CONTRIBUTING.md).

Standard escape-time modules use the slot definitions in `lib/core/modules/builders/uniform_layout.dart` and the setter in `lib/core/modules/builders/escape_time/builder.dart`. Slots 0 through 9 hold shared values. Extra parameters start at slot 10. Ray-marched 3D modules share a frame/camera prefix through `setRaymarched3DFrameUniforms()`: time at slot 0, resolution at 1–2, pan target (`uMousePos`) at 3–4, zoom at 5, and rotation at 6–8. Module-specific 3D parameters follow that prefix. Mandelbrot double-float has its own layout. Do not reuse an index across shader families without checking its matching builder and shader declarations.

## Coloring coverage

`test/shaders/smooth_coloring_family_coverage_test.dart` checks the following bounded source-level smooth-coloring cases (family labels follow the test):

| Family | Shader paths | Checked coloring form |
|---|---|---|
| Quadratic legacy | `shaders/legacy/escape_time/mandel_step_smooth.frag`, `shaders/legacy/escape_time/julia.frag`, `shaders/legacy/escape_time/burning_ship.frag` | Quadratic `log2(log2(|z|²))` correction; palette coordinate uses the smoothed iteration |
| Quadratic perturbation | `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` | Quadratic correction from saved escaped `finalMag2` |
| Integer-power polynomial | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag`, `shaders/escape_time_family/polynomial_maps/druid_gpu.frag` | Degree-aware correction using the configured power for shared Multibrot, or degree 3 for Druid |
| Rational escape map | `shaders/escape_time_family/geometry_and_ifs/mcmullen_map_gpu.frag` | Degree-aware correction using its `nf` parameter |
| Quadratic Buffalo | `shaders/escape_time_family/families/buffalo/buffalo_gpu.frag` | Quadratic `log2(log2(|z|²))` correction |
| Powered Buffalo | `shaders/escape_time_family/families/buffalo/power_plane/buffalo_power_gpu.frag` | Configurable-power correction divides `log2(log2(mag2))` by `log2(max(power, 1.0001))` |
| Powered Celtic | `shaders/escape_time_family/families/celtic/power_plane/celtic_power_gpu.frag` | Configurable-power correction divides `log2(log2(mag2))` by `log2(max(power, 1.0001))` |
| Transcendental map | `shaders/escape_time_family/transcendental_maps/collatz_gpu.frag` | Escape-iteration correction `it - log2(log2(|z|²))`; palette coordinate uses the smoothed iteration |
| Feather map | `shaders/escape_time_family/julia_variants/feather_gpu.frag`, `shaders/escape_time_family/julia_variants/feather_julia_gpu.frag` | Degree-3 correction; normal-map palette coordinate uses the smoothed iteration |
| Shark Fin map | `shaders/escape_time_family/polynomial_maps/shark_fin_gpu.frag` | Quadratic correction; standard palette coordinate uses the smoothed iteration |
| Phoenix memory map | `shaders/escape_time_family/core/phoenix_gpu.frag` | Memory-term quadratic recurrence; escaped magnitude correction feeds the standard palette coordinate |

The regression asserts each listed shader's expected formula, its use in the escaped-pixel palette coordinate, and distinct inside-set output. These are bounded source assertions only, not visual or hardware-GPU qualification. In particular, the shared Multibrot case asserts the standard palette coordinate, not its normal-map branch.

The live catalog uses shared configurable-power shaders, not dedicated degree-specific assets:

| Module | Live shader binding | Default power |
|---|---|---|
| `multibrot3` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 3 |
| `multibrot4` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 4 |
| `multibrot5` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 5 |
| `multibrot6` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 6 |
| `multibrot7` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 7 |
| `multibrot8` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 8 |
| `multibrot9` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 9 |
| `multibrot10` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 10 |
| `multibrot11` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 11 |
| `multibrot12` | `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 12 |
| `buffalo_cubic` | `shaders/escape_time_family/families/buffalo/power_plane/buffalo_power_gpu.frag` | 3 |

Catalog owners are `lib/core/modules/builders/escape_time_catalog/families/core_escape_time_family.dart` (d=3), `lib/core/modules/builders/escape_time_catalog/families/cellular_stochastic.dart` (d=4–5), `lib/core/modules/builders/escape_time_catalog/research_batches/batch_14_extensions.dart` (d=6–12), and `lib/core/modules/builders/escape_time_catalog/research_batches/mandlebrot_sfml_batch_1.dart` (Buffalo Cubic).

For Multibrot d=3–12, the shared shader computes `logZn = 0.5 * log(mag2)` and `smoothVal = float(it) + 1.0 - log(max(1e-12, logZn)) / log(max(1.001, abs(power)))`. The source regression checks that configurable formula once, not a separate source case for each degree. Buffalo Cubic defaults to power 3 in the shared powered-Buffalo shader; its checked formula is `smoothVal = float(it) - log2(log2(mag2)) / log2(max(power, 1.0001))`, not a dedicated cubic-source formula.

The separate higher-degree Multibrot fixture is numeric-only: for degrees 5–12 it checks the arithmetic example `iterations - log2(log2(magnitudeSquared)) / log2(degree)` changes the palette coordinate from raw iterations. These are not per-degree shader-source assertions and not rendered proof; the fixture does not read shader files or establish equivalence with the shared shader's formula. The separate Phoenix fixture does read its shader source and also checks a numeric palette example, but does not render pixels.

The integer-power inventory does not qualify the non-integer degree 1.5/2.5 variants or the negative-power map, even where they share a shader. Those parameter variants, the other shader families and unlisted shaders remain outside this bounded audit, so P1-3 is still open for a complete audit.

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
