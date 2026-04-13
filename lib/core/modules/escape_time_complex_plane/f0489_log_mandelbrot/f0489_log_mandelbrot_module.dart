// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0489_log_mandelbrot_presets.dart';
import 'f0489_log_mandelbrot_variants.dart';
import 'f0489_log_mandelbrot_metadata.dart';

/// Log Mandelbrot — Escape-Time (Complex Plane).
class F0489LogMandelbrot extends EscapeTimeModule {
  F0489LogMandelbrot()
      : super(
          id: 'f0489_log_mandelbrot',
          shader: 'shaders/f0489_log_mandelbrot_gpu.frag',
        );

  @override
  F0489LogMandelbrotMetadata get metadata => F0489LogMandelbrotMetadata.instance;

  @override
  List<F0489LogMandelbrotPreset> get presets => F0489LogMandelbrotPresets.all;

  @override
  List<F0489LogMandelbrotVariant> get variants => F0489LogMandelbrotVariants.all;

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
