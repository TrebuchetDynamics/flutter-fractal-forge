// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1020_brian_s_brain_presets.dart';
import 'f1020_brian_s_brain_variants.dart';
import 'f1020_brian_s_brain_metadata.dart';

/// Brian's Brain — Cellular & Stochastic.
class F1020BrianSBrain extends CellularModule {
  F1020BrianSBrain()
      : super(
          id: 'f1020_brian_s_brain',
          shader: 'shaders/f1020_brian_s_brain_gpu.frag',
        );

  @override
  F1020BrianSBrainMetadata get metadata => F1020BrianSBrainMetadata.instance;

  @override
  List<F1020BrianSBrainPreset> get presets => F1020BrianSBrainPresets.all;

  @override
  List<F1020BrianSBrainVariant> get variants => F1020BrianSBrainVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
