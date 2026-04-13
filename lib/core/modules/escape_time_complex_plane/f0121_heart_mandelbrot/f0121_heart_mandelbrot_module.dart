// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0121_heart_mandelbrot_presets.dart';
import 'f0121_heart_mandelbrot_variants.dart';
import 'f0121_heart_mandelbrot_metadata.dart';

/// Heart Mandelbrot — Escape-Time (Complex Plane).
class F0121HeartMandelbrot extends EscapeTimeModule {
  F0121HeartMandelbrot()
      : super(
          id: 'f0121_heart_mandelbrot',
          shader: 'shaders/f0121_heart_mandelbrot_gpu.frag',
        );

  @override
  F0121HeartMandelbrotMetadata get metadata => F0121HeartMandelbrotMetadata.instance;

  @override
  List<F0121HeartMandelbrotPreset> get presets => F0121HeartMandelbrotPresets.all;

  @override
  List<F0121HeartMandelbrotVariant> get variants => F0121HeartMandelbrotVariants.all;

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
