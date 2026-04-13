// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0064_newton_leipnik_presets.dart';
import 'f0064_newton_leipnik_variants.dart';
import 'f0064_newton_leipnik_metadata.dart';

/// Newton-Leipnik — Strange Attractors.
class F0064NewtonLeipnik extends AttractorModule {
  F0064NewtonLeipnik()
      : super(
          id: 'f0064_newton_leipnik',
          shader: 'shaders/f0064_newton_leipnik_gpu.frag',
        );

  @override
  F0064NewtonLeipnikMetadata get metadata => F0064NewtonLeipnikMetadata.instance;

  @override
  List<F0064NewtonLeipnikPreset> get presets => F0064NewtonLeipnikPresets.all;

  @override
  List<F0064NewtonLeipnikVariant> get variants => F0064NewtonLeipnikVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
