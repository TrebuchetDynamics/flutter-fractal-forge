// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1072_rulkov_bursting_presets.dart';
import 'f1072_rulkov_bursting_variants.dart';
import 'f1072_rulkov_bursting_metadata.dart';

/// Rulkov Bursting — Strange Attractors.
class F1072RulkovBursting extends AttractorModule {
  F1072RulkovBursting()
      : super(
          id: 'f1072_rulkov_bursting',
          shader: 'shaders/f1072_rulkov_bursting_gpu.frag',
        );

  @override
  F1072RulkovBurstingMetadata get metadata => F1072RulkovBurstingMetadata.instance;

  @override
  List<F1072RulkovBurstingPreset> get presets => F1072RulkovBurstingPresets.all;

  @override
  List<F1072RulkovBurstingVariant> get variants => F1072RulkovBurstingVariants.all;

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
