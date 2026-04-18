// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0998_3_4_life_b34_s34_presets.dart';
import 'f0998_3_4_life_b34_s34_variants.dart';
import 'f0998_3_4_life_b34_s34_metadata.dart';

/// 3-4 Life (B34/S34) — Cellular & Stochastic.
class F099834LifeB34S34 extends CellularModule {
  F099834LifeB34S34()
      : super(
          id: 'f0998_3_4_life_b34_s34',
          shader: 'shaders/f0998_3_4_life_b34_s34_gpu.frag',
        );

  @override
  F099834LifeB34S34Metadata get metadata => F099834LifeB34S34Metadata.instance;

  @override
  List<F099834LifeB34S34Preset> get presets => F099834LifeB34S34Presets.all;

  @override
  List<F099834LifeB34S34Variant> get variants => F099834LifeB34S34Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
