// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0960_elementary_ca_rule_198_presets.dart';
import 'f0960_elementary_ca_rule_198_variants.dart';
import 'f0960_elementary_ca_rule_198_metadata.dart';

/// Elementary CA Rule 198 — Cellular & Stochastic.
class F0960ElementaryCaRule198 extends CellularModule {
  F0960ElementaryCaRule198()
      : super(
          id: 'f0960_elementary_ca_rule_198',
          shader: 'shaders/f0960_elementary_ca_rule_198_gpu.frag',
        );

  @override
  F0960ElementaryCaRule198Metadata get metadata => F0960ElementaryCaRule198Metadata.instance;

  @override
  List<F0960ElementaryCaRule198Preset> get presets => F0960ElementaryCaRule198Presets.all;

  @override
  List<F0960ElementaryCaRule198Variant> get variants => F0960ElementaryCaRule198Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
