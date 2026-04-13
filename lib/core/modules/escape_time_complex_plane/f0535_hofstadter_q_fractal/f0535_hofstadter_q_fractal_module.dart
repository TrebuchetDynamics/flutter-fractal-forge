// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0535_hofstadter_q_fractal_presets.dart';
import 'f0535_hofstadter_q_fractal_variants.dart';
import 'f0535_hofstadter_q_fractal_metadata.dart';

/// Hofstadter Q Fractal — Escape-Time (Complex Plane).
class F0535HofstadterQFractal extends EscapeTimeModule {
  F0535HofstadterQFractal()
      : super(
          id: 'f0535_hofstadter_q_fractal',
          shader: 'shaders/f0535_hofstadter_q_fractal_gpu.frag',
        );

  @override
  F0535HofstadterQFractalMetadata get metadata => F0535HofstadterQFractalMetadata.instance;

  @override
  List<F0535HofstadterQFractalPreset> get presets => F0535HofstadterQFractalPresets.all;

  @override
  List<F0535HofstadterQFractalVariant> get variants => F0535HofstadterQFractalVariants.all;

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
