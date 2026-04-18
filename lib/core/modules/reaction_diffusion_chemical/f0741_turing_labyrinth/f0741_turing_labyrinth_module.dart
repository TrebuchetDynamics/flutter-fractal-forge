// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0741_turing_labyrinth_presets.dart';
import 'f0741_turing_labyrinth_variants.dart';
import 'f0741_turing_labyrinth_metadata.dart';

/// Turing Labyrinth — Reaction-Diffusion & Chemical.
class F0741TuringLabyrinth extends CellularModule {
  F0741TuringLabyrinth()
      : super(
          id: 'f0741_turing_labyrinth',
          shader: 'shaders/f0741_turing_labyrinth_gpu.frag',
        );

  @override
  F0741TuringLabyrinthMetadata get metadata => F0741TuringLabyrinthMetadata.instance;

  @override
  List<F0741TuringLabyrinthPreset> get presets => F0741TuringLabyrinthPresets.all;

  @override
  List<F0741TuringLabyrinthVariant> get variants => F0741TuringLabyrinthVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
