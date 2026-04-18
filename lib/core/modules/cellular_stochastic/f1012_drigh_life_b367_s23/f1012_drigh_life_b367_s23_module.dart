// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1012_drigh_life_b367_s23_presets.dart';
import 'f1012_drigh_life_b367_s23_variants.dart';
import 'f1012_drigh_life_b367_s23_metadata.dart';

/// Drigh Life (B367/S23) — Cellular & Stochastic.
class F1012DrighLifeB367S23 extends CellularModule {
  F1012DrighLifeB367S23()
      : super(
          id: 'f1012_drigh_life_b367_s23',
          shader: 'shaders/f1012_drigh_life_b367_s23_gpu.frag',
        );

  @override
  F1012DrighLifeB367S23Metadata get metadata => F1012DrighLifeB367S23Metadata.instance;

  @override
  List<F1012DrighLifeB367S23Preset> get presets => F1012DrighLifeB367S23Presets.all;

  @override
  List<F1012DrighLifeB367S23Variant> get variants => F1012DrighLifeB367S23Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
