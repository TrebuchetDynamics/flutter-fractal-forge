// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1004_land_rush_b35_s234578_presets.dart';
import 'f1004_land_rush_b35_s234578_variants.dart';
import 'f1004_land_rush_b35_s234578_metadata.dart';

/// Land Rush (B35/S234578) — Cellular & Stochastic.
class F1004LandRushB35S234578 extends CellularModule {
  F1004LandRushB35S234578()
      : super(
          id: 'f1004_land_rush_b35_s234578',
          shader: 'shaders/f1004_land_rush_b35_s234578_gpu.frag',
        );

  @override
  F1004LandRushB35S234578Metadata get metadata => F1004LandRushB35S234578Metadata.instance;

  @override
  List<F1004LandRushB35S234578Preset> get presets => F1004LandRushB35S234578Presets.all;

  @override
  List<F1004LandRushB35S234578Variant> get variants => F1004LandRushB35S234578Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
