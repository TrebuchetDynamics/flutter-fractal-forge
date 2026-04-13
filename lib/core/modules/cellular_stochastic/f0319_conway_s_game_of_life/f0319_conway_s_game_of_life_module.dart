// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0319_conway_s_game_of_life_presets.dart';
import 'f0319_conway_s_game_of_life_variants.dart';
import 'f0319_conway_s_game_of_life_metadata.dart';

/// Conway's Game of Life — Cellular & Stochastic.
class F0319ConwaySGameOfLife extends CellularModule {
  F0319ConwaySGameOfLife()
      : super(
          id: 'f0319_conway_s_game_of_life',
          shader: 'shaders/f0319_conway_s_game_of_life_gpu.frag',
        );

  @override
  F0319ConwaySGameOfLifeMetadata get metadata => F0319ConwaySGameOfLifeMetadata.instance;

  @override
  List<F0319ConwaySGameOfLifePreset> get presets => F0319ConwaySGameOfLifePresets.all;

  @override
  List<F0319ConwaySGameOfLifeVariant> get variants => F0319ConwaySGameOfLifeVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
