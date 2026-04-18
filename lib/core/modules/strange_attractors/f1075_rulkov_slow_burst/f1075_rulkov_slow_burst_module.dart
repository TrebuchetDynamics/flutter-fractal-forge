// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1075_rulkov_slow_burst_presets.dart';
import 'f1075_rulkov_slow_burst_variants.dart';
import 'f1075_rulkov_slow_burst_metadata.dart';

/// Rulkov Slow Burst — Strange Attractors.
class F1075RulkovSlowBurst extends AttractorModule {
  F1075RulkovSlowBurst()
      : super(
          id: 'f1075_rulkov_slow_burst',
          shader: 'shaders/f1075_rulkov_slow_burst_gpu.frag',
        );

  @override
  F1075RulkovSlowBurstMetadata get metadata => F1075RulkovSlowBurstMetadata.instance;

  @override
  List<F1075RulkovSlowBurstPreset> get presets => F1075RulkovSlowBurstPresets.all;

  @override
  List<F1075RulkovSlowBurstVariant> get variants => F1075RulkovSlowBurstVariants.all;

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
