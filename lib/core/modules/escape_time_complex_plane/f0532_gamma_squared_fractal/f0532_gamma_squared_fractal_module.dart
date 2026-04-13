// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0532_gamma_squared_fractal_presets.dart';
import 'f0532_gamma_squared_fractal_variants.dart';
import 'f0532_gamma_squared_fractal_metadata.dart';

/// Gamma-Squared Fractal — Escape-Time (Complex Plane).
class F0532GammaSquaredFractal extends EscapeTimeModule {
  F0532GammaSquaredFractal()
      : super(
          id: 'f0532_gamma_squared_fractal',
          shader: 'shaders/f0532_gamma_squared_fractal_gpu.frag',
        );

  @override
  F0532GammaSquaredFractalMetadata get metadata => F0532GammaSquaredFractalMetadata.instance;

  @override
  List<F0532GammaSquaredFractalPreset> get presets => F0532GammaSquaredFractalPresets.all;

  @override
  List<F0532GammaSquaredFractalVariant> get variants => F0532GammaSquaredFractalVariants.all;

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
