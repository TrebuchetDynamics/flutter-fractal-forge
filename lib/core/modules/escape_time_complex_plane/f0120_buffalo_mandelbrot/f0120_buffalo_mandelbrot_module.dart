// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0120_buffalo_mandelbrot_presets.dart';
import 'f0120_buffalo_mandelbrot_variants.dart';
import 'f0120_buffalo_mandelbrot_metadata.dart';

/// Buffalo Mandelbrot — Escape-Time (Complex Plane).
class F0120BuffaloMandelbrot extends EscapeTimeModule {
  F0120BuffaloMandelbrot()
      : super(
          id: 'f0120_buffalo_mandelbrot',
          shader: 'shaders/f0120_buffalo_mandelbrot_gpu.frag',
        );

  @override
  F0120BuffaloMandelbrotMetadata get metadata => F0120BuffaloMandelbrotMetadata.instance;

  @override
  List<F0120BuffaloMandelbrotPreset> get presets => F0120BuffaloMandelbrotPresets.all;

  @override
  List<F0120BuffaloMandelbrotVariant> get variants => F0120BuffaloMandelbrotVariants.all;

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
