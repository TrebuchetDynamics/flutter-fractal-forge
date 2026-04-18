// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0758_farey_sequence_fractal_presets.dart';
import 'f0758_farey_sequence_fractal_variants.dart';
import 'f0758_farey_sequence_fractal_metadata.dart';

/// Farey Sequence Fractal — Number-Theory Fractals.
class F0758FareySequenceFractal extends CellularModule {
  F0758FareySequenceFractal()
      : super(
          id: 'f0758_farey_sequence_fractal',
          shader: 'shaders/f0758_farey_sequence_fractal_gpu.frag',
        );

  @override
  F0758FareySequenceFractalMetadata get metadata => F0758FareySequenceFractalMetadata.instance;

  @override
  List<F0758FareySequenceFractalPreset> get presets => F0758FareySequenceFractalPresets.all;

  @override
  List<F0758FareySequenceFractalVariant> get variants => F0758FareySequenceFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
