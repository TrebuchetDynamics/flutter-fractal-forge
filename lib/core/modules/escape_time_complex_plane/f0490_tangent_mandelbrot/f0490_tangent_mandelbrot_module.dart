// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0490_tangent_mandelbrot_presets.dart';
import 'f0490_tangent_mandelbrot_variants.dart';
import 'f0490_tangent_mandelbrot_metadata.dart';

/// Tangent Mandelbrot — Escape-Time (Complex Plane).
class F0490TangentMandelbrot extends EscapeTimeModule {
  F0490TangentMandelbrot()
      : super(
          id: 'f0490_tangent_mandelbrot',
          shader: 'shaders/f0490_tangent_mandelbrot_gpu.frag',
        );

  @override
  F0490TangentMandelbrotMetadata get metadata => F0490TangentMandelbrotMetadata.instance;

  @override
  List<F0490TangentMandelbrotPreset> get presets => F0490TangentMandelbrotPresets.all;

  @override
  List<F0490TangentMandelbrotVariant> get variants => F0490TangentMandelbrotVariants.all;

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
