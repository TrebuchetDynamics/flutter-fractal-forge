// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0996_walled_cities_b45678_s2345_presets.dart';
import 'f0996_walled_cities_b45678_s2345_variants.dart';
import 'f0996_walled_cities_b45678_s2345_metadata.dart';

/// Walled Cities (B45678/S2345) — Cellular & Stochastic.
class F0996WalledCitiesB45678S2345 extends CellularModule {
  F0996WalledCitiesB45678S2345()
      : super(
          id: 'f0996_walled_cities_b45678_s2345',
          shader: 'shaders/f0996_walled_cities_b45678_s2345_gpu.frag',
        );

  @override
  F0996WalledCitiesB45678S2345Metadata get metadata => F0996WalledCitiesB45678S2345Metadata.instance;

  @override
  List<F0996WalledCitiesB45678S2345Preset> get presets => F0996WalledCitiesB45678S2345Presets.all;

  @override
  List<F0996WalledCitiesB45678S2345Variant> get variants => F0996WalledCitiesB45678S2345Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
