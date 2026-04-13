// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0531_gamma_mandelbrot_presets.dart';
import 'f0531_gamma_mandelbrot_variants.dart';
import 'f0531_gamma_mandelbrot_metadata.dart';

/// Gamma Mandelbrot — Escape-Time (Complex Plane).
class F0531GammaMandelbrot extends EscapeTimeModule {
  F0531GammaMandelbrot()
      : super(
          id: 'f0531_gamma_mandelbrot',
          shader: 'shaders/f0531_gamma_mandelbrot_gpu.frag',
        );

  @override
  F0531GammaMandelbrotMetadata get metadata => F0531GammaMandelbrotMetadata.instance;

  @override
  List<F0531GammaMandelbrotPreset> get presets => F0531GammaMandelbrotPresets.all;

  @override
  List<F0531GammaMandelbrotVariant> get variants => F0531GammaMandelbrotVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
