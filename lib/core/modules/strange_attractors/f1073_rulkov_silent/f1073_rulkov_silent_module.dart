// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1073_rulkov_silent_presets.dart';
import 'f1073_rulkov_silent_variants.dart';
import 'f1073_rulkov_silent_metadata.dart';

/// Rulkov Silent — Strange Attractors.
class F1073RulkovSilent extends AttractorModule {
  F1073RulkovSilent()
      : super(
          id: 'f1073_rulkov_silent',
          shader: 'shaders/f1073_rulkov_silent_gpu.frag',
        );

  @override
  F1073RulkovSilentMetadata get metadata => F1073RulkovSilentMetadata.instance;

  @override
  List<F1073RulkovSilentPreset> get presets => F1073RulkovSilentPresets.all;

  @override
  List<F1073RulkovSilentVariant> get variants => F1073RulkovSilentVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
