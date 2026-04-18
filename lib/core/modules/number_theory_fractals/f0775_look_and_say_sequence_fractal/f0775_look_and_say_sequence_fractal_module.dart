// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0775_look_and_say_sequence_fractal_presets.dart';
import 'f0775_look_and_say_sequence_fractal_variants.dart';
import 'f0775_look_and_say_sequence_fractal_metadata.dart';

/// Look-and-Say Sequence Fractal — Number-Theory Fractals.
class F0775LookAndSaySequenceFractal extends CellularModule {
  F0775LookAndSaySequenceFractal()
      : super(
          id: 'f0775_look_and_say_sequence_fractal',
          shader: 'shaders/f0775_look_and_say_sequence_fractal_gpu.frag',
        );

  @override
  F0775LookAndSaySequenceFractalMetadata get metadata => F0775LookAndSaySequenceFractalMetadata.instance;

  @override
  List<F0775LookAndSaySequenceFractalPreset> get presets => F0775LookAndSaySequenceFractalPresets.all;

  @override
  List<F0775LookAndSaySequenceFractalVariant> get variants => F0775LookAndSaySequenceFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
