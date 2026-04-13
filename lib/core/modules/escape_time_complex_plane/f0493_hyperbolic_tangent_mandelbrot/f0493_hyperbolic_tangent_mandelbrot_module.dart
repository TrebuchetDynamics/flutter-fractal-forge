// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0493_hyperbolic_tangent_mandelbrot_presets.dart';
import 'f0493_hyperbolic_tangent_mandelbrot_variants.dart';
import 'f0493_hyperbolic_tangent_mandelbrot_metadata.dart';

/// Hyperbolic Tangent Mandelbrot — Escape-Time (Complex Plane).
class F0493HyperbolicTangentMandelbrot extends EscapeTimeModule {
  F0493HyperbolicTangentMandelbrot()
      : super(
          id: 'f0493_hyperbolic_tangent_mandelbrot',
          shader: 'shaders/f0493_hyperbolic_tangent_mandelbrot_gpu.frag',
        );

  @override
  F0493HyperbolicTangentMandelbrotMetadata get metadata => F0493HyperbolicTangentMandelbrotMetadata.instance;

  @override
  List<F0493HyperbolicTangentMandelbrotPreset> get presets => F0493HyperbolicTangentMandelbrotPresets.all;

  @override
  List<F0493HyperbolicTangentMandelbrotVariant> get variants => F0493HyperbolicTangentMandelbrotVariants.all;

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
