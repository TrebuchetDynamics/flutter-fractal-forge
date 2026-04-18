// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0772_thue_morse_sequence_presets.dart';
import 'f0772_thue_morse_sequence_variants.dart';
import 'f0772_thue_morse_sequence_metadata.dart';

/// Thue-Morse Sequence — Number-Theory Fractals.
class F0772ThueMorseSequence extends CellularModule {
  F0772ThueMorseSequence()
      : super(
          id: 'f0772_thue_morse_sequence',
          shader: 'shaders/f0772_thue_morse_sequence_gpu.frag',
        );

  @override
  F0772ThueMorseSequenceMetadata get metadata => F0772ThueMorseSequenceMetadata.instance;

  @override
  List<F0772ThueMorseSequencePreset> get presets => F0772ThueMorseSequencePresets.all;

  @override
  List<F0772ThueMorseSequenceVariant> get variants => F0772ThueMorseSequenceVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
