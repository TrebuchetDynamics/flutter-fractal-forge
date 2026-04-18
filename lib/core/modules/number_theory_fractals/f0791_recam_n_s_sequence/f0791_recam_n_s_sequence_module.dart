// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0791_recam_n_s_sequence_presets.dart';
import 'f0791_recam_n_s_sequence_variants.dart';
import 'f0791_recam_n_s_sequence_metadata.dart';

/// Recamán's Sequence — Number-Theory Fractals.
class F0791RecamNSSequence extends CellularModule {
  F0791RecamNSSequence()
      : super(
          id: 'f0791_recam_n_s_sequence',
          shader: 'shaders/f0791_recam_n_s_sequence_gpu.frag',
        );

  @override
  F0791RecamNSSequenceMetadata get metadata => F0791RecamNSSequenceMetadata.instance;

  @override
  List<F0791RecamNSSequencePreset> get presets => F0791RecamNSSequencePresets.all;

  @override
  List<F0791RecamNSSequenceVariant> get variants => F0791RecamNSSequenceVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
