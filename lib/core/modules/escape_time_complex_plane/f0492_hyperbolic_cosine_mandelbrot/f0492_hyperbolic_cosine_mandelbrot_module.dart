// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0492_hyperbolic_cosine_mandelbrot_presets.dart';
import 'f0492_hyperbolic_cosine_mandelbrot_variants.dart';
import 'f0492_hyperbolic_cosine_mandelbrot_metadata.dart';

/// Hyperbolic Cosine Mandelbrot — Escape-Time (Complex Plane).
class F0492HyperbolicCosineMandelbrot extends EscapeTimeModule {
  F0492HyperbolicCosineMandelbrot()
      : super(
          id: 'f0492_hyperbolic_cosine_mandelbrot',
          shader: 'shaders/f0492_hyperbolic_cosine_mandelbrot_gpu.frag',
        );

  @override
  F0492HyperbolicCosineMandelbrotMetadata get metadata => F0492HyperbolicCosineMandelbrotMetadata.instance;

  @override
  List<F0492HyperbolicCosineMandelbrotPreset> get presets => F0492HyperbolicCosineMandelbrotPresets.all;

  @override
  List<F0492HyperbolicCosineMandelbrotVariant> get variants => F0492HyperbolicCosineMandelbrotVariants.all;

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
