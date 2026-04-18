// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0776_kolakoski_sequence_presets.dart';
import 'f0776_kolakoski_sequence_variants.dart';
import 'f0776_kolakoski_sequence_metadata.dart';

/// Kolakoski Sequence — Number-Theory Fractals.
class F0776KolakoskiSequence extends CellularModule {
  F0776KolakoskiSequence()
      : super(
          id: 'f0776_kolakoski_sequence',
          shader: 'shaders/f0776_kolakoski_sequence_gpu.frag',
        );

  @override
  F0776KolakoskiSequenceMetadata get metadata => F0776KolakoskiSequenceMetadata.instance;

  @override
  List<F0776KolakoskiSequencePreset> get presets => F0776KolakoskiSequencePresets.all;

  @override
  List<F0776KolakoskiSequenceVariant> get variants => F0776KolakoskiSequenceVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
