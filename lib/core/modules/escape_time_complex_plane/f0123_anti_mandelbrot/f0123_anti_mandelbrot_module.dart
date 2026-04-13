// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0123_anti_mandelbrot_presets.dart';
import 'f0123_anti_mandelbrot_variants.dart';
import 'f0123_anti_mandelbrot_metadata.dart';

/// Anti-Mandelbrot — Escape-Time (Complex Plane).
class F0123AntiMandelbrot extends EscapeTimeModule {
  F0123AntiMandelbrot()
      : super(
          id: 'f0123_anti_mandelbrot',
          shader: 'shaders/f0123_anti_mandelbrot_gpu.frag',
        );

  @override
  F0123AntiMandelbrotMetadata get metadata => F0123AntiMandelbrotMetadata.instance;

  @override
  List<F0123AntiMandelbrotPreset> get presets => F0123AntiMandelbrotPresets.all;

  @override
  List<F0123AntiMandelbrotVariant> get variants => F0123AntiMandelbrotVariants.all;

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
