// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0989_long_life_b345_s5_presets.dart';
import 'f0989_long_life_b345_s5_variants.dart';
import 'f0989_long_life_b345_s5_metadata.dart';

/// Long Life (B345/S5) — Cellular & Stochastic.
class F0989LongLifeB345S5 extends CellularModule {
  F0989LongLifeB345S5()
      : super(
          id: 'f0989_long_life_b345_s5',
          shader: 'shaders/f0989_long_life_b345_s5_gpu.frag',
        );

  @override
  F0989LongLifeB345S5Metadata get metadata => F0989LongLifeB345S5Metadata.instance;

  @override
  List<F0989LongLifeB345S5Preset> get presets => F0989LongLifeB345S5Presets.all;

  @override
  List<F0989LongLifeB345S5Variant> get variants => F0989LongLifeB345S5Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
