// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0044_sprott_minimum_chaotic_flow_presets.dart';
import 'f0044_sprott_minimum_chaotic_flow_variants.dart';
import 'f0044_sprott_minimum_chaotic_flow_metadata.dart';

/// Sprott Minimum Chaotic Flow — Strange Attractors.
class F0044SprottMinimumChaoticFlow extends AttractorModule {
  F0044SprottMinimumChaoticFlow()
      : super(
          id: 'f0044_sprott_minimum_chaotic_flow',
          shader: 'shaders/f0044_sprott_minimum_chaotic_flow_gpu.frag',
        );

  @override
  F0044SprottMinimumChaoticFlowMetadata get metadata => F0044SprottMinimumChaoticFlowMetadata.instance;

  @override
  List<F0044SprottMinimumChaoticFlowPreset> get presets => F0044SprottMinimumChaoticFlowPresets.all;

  @override
  List<F0044SprottMinimumChaoticFlowVariant> get variants => F0044SprottMinimumChaoticFlowVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
