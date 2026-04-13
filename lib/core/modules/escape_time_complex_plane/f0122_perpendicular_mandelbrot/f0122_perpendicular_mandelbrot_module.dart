// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0122_perpendicular_mandelbrot_presets.dart';
import 'f0122_perpendicular_mandelbrot_variants.dart';
import 'f0122_perpendicular_mandelbrot_metadata.dart';

/// Perpendicular Mandelbrot — Escape-Time (Complex Plane).
class F0122PerpendicularMandelbrot extends EscapeTimeModule {
  F0122PerpendicularMandelbrot()
      : super(
          id: 'f0122_perpendicular_mandelbrot',
          shader: 'shaders/f0122_perpendicular_mandelbrot_gpu.frag',
        );

  @override
  F0122PerpendicularMandelbrotMetadata get metadata => F0122PerpendicularMandelbrotMetadata.instance;

  @override
  List<F0122PerpendicularMandelbrotPreset> get presets => F0122PerpendicularMandelbrotPresets.all;

  @override
  List<F0122PerpendicularMandelbrotVariant> get variants => F0122PerpendicularMandelbrotVariants.all;

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
