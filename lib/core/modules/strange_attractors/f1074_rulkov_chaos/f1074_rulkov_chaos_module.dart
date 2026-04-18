// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1074_rulkov_chaos_presets.dart';
import 'f1074_rulkov_chaos_variants.dart';
import 'f1074_rulkov_chaos_metadata.dart';

/// Rulkov Chaos — Strange Attractors.
class F1074RulkovChaos extends AttractorModule {
  F1074RulkovChaos()
      : super(
          id: 'f1074_rulkov_chaos',
          shader: 'shaders/f1074_rulkov_chaos_gpu.frag',
        );

  @override
  F1074RulkovChaosMetadata get metadata => F1074RulkovChaosMetadata.instance;

  @override
  List<F1074RulkovChaosPreset> get presets => F1074RulkovChaosPresets.all;

  @override
  List<F1074RulkovChaosVariant> get variants => F1074RulkovChaosVariants.all;

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
