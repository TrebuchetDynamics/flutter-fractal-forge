// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0487_cosine_mandelbrot_presets.dart';
import 'f0487_cosine_mandelbrot_variants.dart';
import 'f0487_cosine_mandelbrot_metadata.dart';

/// Cosine Mandelbrot — Escape-Time (Complex Plane).
class F0487CosineMandelbrot extends EscapeTimeModule {
  F0487CosineMandelbrot()
      : super(
          id: 'f0487_cosine_mandelbrot',
          shader: 'shaders/f0487_cosine_mandelbrot_gpu.frag',
        );

  @override
  F0487CosineMandelbrotMetadata get metadata => F0487CosineMandelbrotMetadata.instance;

  @override
  List<F0487CosineMandelbrotPreset> get presets => F0487CosineMandelbrotPresets.all;

  @override
  List<F0487CosineMandelbrotVariant> get variants => F0487CosineMandelbrotVariants.all;

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
