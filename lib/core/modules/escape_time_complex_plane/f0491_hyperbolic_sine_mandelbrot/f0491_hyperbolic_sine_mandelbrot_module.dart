// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0491_hyperbolic_sine_mandelbrot_presets.dart';
import 'f0491_hyperbolic_sine_mandelbrot_variants.dart';
import 'f0491_hyperbolic_sine_mandelbrot_metadata.dart';

/// Hyperbolic Sine Mandelbrot — Escape-Time (Complex Plane).
class F0491HyperbolicSineMandelbrot extends EscapeTimeModule {
  F0491HyperbolicSineMandelbrot()
      : super(
          id: 'f0491_hyperbolic_sine_mandelbrot',
          shader: 'shaders/f0491_hyperbolic_sine_mandelbrot_gpu.frag',
        );

  @override
  F0491HyperbolicSineMandelbrotMetadata get metadata => F0491HyperbolicSineMandelbrotMetadata.instance;

  @override
  List<F0491HyperbolicSineMandelbrotPreset> get presets => F0491HyperbolicSineMandelbrotPresets.all;

  @override
  List<F0491HyperbolicSineMandelbrotVariant> get variants => F0491HyperbolicSineMandelbrotVariants.all;

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
