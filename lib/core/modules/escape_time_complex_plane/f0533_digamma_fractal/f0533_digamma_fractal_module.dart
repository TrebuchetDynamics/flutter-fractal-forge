// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0533_digamma_fractal_presets.dart';
import 'f0533_digamma_fractal_variants.dart';
import 'f0533_digamma_fractal_metadata.dart';

/// Digamma Fractal — Escape-Time (Complex Plane).
class F0533DigammaFractal extends EscapeTimeModule {
  F0533DigammaFractal()
      : super(
          id: 'f0533_digamma_fractal',
          shader: 'shaders/f0533_digamma_fractal_gpu.frag',
        );

  @override
  F0533DigammaFractalMetadata get metadata => F0533DigammaFractalMetadata.instance;

  @override
  List<F0533DigammaFractalPreset> get presets => F0533DigammaFractalPresets.all;

  @override
  List<F0533DigammaFractalVariant> get variants => F0533DigammaFractalVariants.all;

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
