// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1010_pedestrian_life_b38_s23_presets.dart';
import 'f1010_pedestrian_life_b38_s23_variants.dart';
import 'f1010_pedestrian_life_b38_s23_metadata.dart';

/// Pedestrian Life (B38/S23) — Cellular & Stochastic.
class F1010PedestrianLifeB38S23 extends CellularModule {
  F1010PedestrianLifeB38S23()
      : super(
          id: 'f1010_pedestrian_life_b38_s23',
          shader: 'shaders/f1010_pedestrian_life_b38_s23_gpu.frag',
        );

  @override
  F1010PedestrianLifeB38S23Metadata get metadata => F1010PedestrianLifeB38S23Metadata.instance;

  @override
  List<F1010PedestrianLifeB38S23Preset> get presets => F1010PedestrianLifeB38S23Presets.all;

  @override
  List<F1010PedestrianLifeB38S23Variant> get variants => F1010PedestrianLifeB38S23Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
