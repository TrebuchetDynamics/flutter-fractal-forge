// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0488_exponential_mandelbrot_presets.dart';
import 'f0488_exponential_mandelbrot_variants.dart';
import 'f0488_exponential_mandelbrot_metadata.dart';

/// Exponential Mandelbrot — Escape-Time (Complex Plane).
class F0488ExponentialMandelbrot extends EscapeTimeModule {
  F0488ExponentialMandelbrot()
      : super(
          id: 'f0488_exponential_mandelbrot',
          shader: 'shaders/f0488_exponential_mandelbrot_gpu.frag',
        );

  @override
  F0488ExponentialMandelbrotMetadata get metadata => F0488ExponentialMandelbrotMetadata.instance;

  @override
  List<F0488ExponentialMandelbrotPreset> get presets => F0488ExponentialMandelbrotPresets.all;

  @override
  List<F0488ExponentialMandelbrotVariant> get variants => F0488ExponentialMandelbrotVariants.all;

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
