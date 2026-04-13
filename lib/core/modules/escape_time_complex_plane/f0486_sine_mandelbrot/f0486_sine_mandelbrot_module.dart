// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0486_sine_mandelbrot_presets.dart';
import 'f0486_sine_mandelbrot_variants.dart';
import 'f0486_sine_mandelbrot_metadata.dart';

/// Sine Mandelbrot — Escape-Time (Complex Plane).
class F0486SineMandelbrot extends EscapeTimeModule {
  F0486SineMandelbrot()
      : super(
          id: 'f0486_sine_mandelbrot',
          shader: 'shaders/f0486_sine_mandelbrot_gpu.frag',
        );

  @override
  F0486SineMandelbrotMetadata get metadata => F0486SineMandelbrotMetadata.instance;

  @override
  List<F0486SineMandelbrotPreset> get presets => F0486SineMandelbrotPresets.all;

  @override
  List<F0486SineMandelbrotVariant> get variants => F0486SineMandelbrotVariants.all;

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
