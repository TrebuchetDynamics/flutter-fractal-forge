// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1076_rulkov_fast_spike_presets.dart';
import 'f1076_rulkov_fast_spike_variants.dart';
import 'f1076_rulkov_fast_spike_metadata.dart';

/// Rulkov Fast Spike — Strange Attractors.
class F1076RulkovFastSpike extends AttractorModule {
  F1076RulkovFastSpike()
      : super(
          id: 'f1076_rulkov_fast_spike',
          shader: 'shaders/f1076_rulkov_fast_spike_gpu.frag',
        );

  @override
  F1076RulkovFastSpikeMetadata get metadata => F1076RulkovFastSpikeMetadata.instance;

  @override
  List<F1076RulkovFastSpikePreset> get presets => F1076RulkovFastSpikePresets.all;

  @override
  List<F1076RulkovFastSpikeVariant> get variants => F1076RulkovFastSpikeVariants.all;

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
