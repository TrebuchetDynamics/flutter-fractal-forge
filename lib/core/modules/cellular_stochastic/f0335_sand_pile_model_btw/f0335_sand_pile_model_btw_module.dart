// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0335_sand_pile_model_btw_presets.dart';
import 'f0335_sand_pile_model_btw_variants.dart';
import 'f0335_sand_pile_model_btw_metadata.dart';

/// Sand Pile Model (BTW) — Cellular & Stochastic.
class F0335SandPileModelBtw extends CellularModule {
  F0335SandPileModelBtw()
      : super(
          id: 'f0335_sand_pile_model_btw',
          shader: 'shaders/f0335_sand_pile_model_btw_gpu.frag',
        );

  @override
  F0335SandPileModelBtwMetadata get metadata => F0335SandPileModelBtwMetadata.instance;

  @override
  List<F0335SandPileModelBtwPreset> get presets => F0335SandPileModelBtwPresets.all;

  @override
  List<F0335SandPileModelBtwVariant> get variants => F0335SandPileModelBtwVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
