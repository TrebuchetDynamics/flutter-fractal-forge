// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0985_2x2_b36_s125_presets.dart';
import 'f0985_2x2_b36_s125_variants.dart';
import 'f0985_2x2_b36_s125_metadata.dart';

/// 2x2 (B36/S125) — Cellular & Stochastic.
class F09852x2B36S125 extends CellularModule {
  F09852x2B36S125()
      : super(
          id: 'f0985_2x2_b36_s125',
          shader: 'shaders/f0985_2x2_b36_s125_gpu.frag',
        );

  @override
  F09852x2B36S125Metadata get metadata => F09852x2B36S125Metadata.instance;

  @override
  List<F09852x2B36S125Preset> get presets => F09852x2B36S125Presets.all;

  @override
  List<F09852x2B36S125Variant> get variants => F09852x2B36S125Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
