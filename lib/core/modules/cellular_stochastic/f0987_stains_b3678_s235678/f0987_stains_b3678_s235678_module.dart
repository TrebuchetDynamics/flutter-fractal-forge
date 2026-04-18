// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0987_stains_b3678_s235678_presets.dart';
import 'f0987_stains_b3678_s235678_variants.dart';
import 'f0987_stains_b3678_s235678_metadata.dart';

/// Stains (B3678/S235678) — Cellular & Stochastic.
class F0987StainsB3678S235678 extends CellularModule {
  F0987StainsB3678S235678()
      : super(
          id: 'f0987_stains_b3678_s235678',
          shader: 'shaders/f0987_stains_b3678_s235678_gpu.frag',
        );

  @override
  F0987StainsB3678S235678Metadata get metadata => F0987StainsB3678S235678Metadata.instance;

  @override
  List<F0987StainsB3678S235678Preset> get presets => F0987StainsB3678S235678Presets.all;

  @override
  List<F0987StainsB3678S235678Variant> get variants => F0987StainsB3678S235678Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
