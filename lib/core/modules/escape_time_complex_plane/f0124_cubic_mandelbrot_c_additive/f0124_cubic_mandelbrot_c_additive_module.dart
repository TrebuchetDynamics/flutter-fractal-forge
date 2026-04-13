// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0124_cubic_mandelbrot_c_additive_presets.dart';
import 'f0124_cubic_mandelbrot_c_additive_variants.dart';
import 'f0124_cubic_mandelbrot_c_additive_metadata.dart';

/// Cubic Mandelbrot (c-additive) — Escape-Time (Complex Plane).
class F0124CubicMandelbrotCAdditive extends EscapeTimeModule {
  F0124CubicMandelbrotCAdditive()
      : super(
          id: 'f0124_cubic_mandelbrot_c_additive',
          shader: 'shaders/f0124_cubic_mandelbrot_c_additive_gpu.frag',
        );

  @override
  F0124CubicMandelbrotCAdditiveMetadata get metadata => F0124CubicMandelbrotCAdditiveMetadata.instance;

  @override
  List<F0124CubicMandelbrotCAdditivePreset> get presets => F0124CubicMandelbrotCAdditivePresets.all;

  @override
  List<F0124CubicMandelbrotCAdditiveVariant> get variants => F0124CubicMandelbrotCAdditiveVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
