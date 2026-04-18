// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0922_elementary_ca_rule_108_presets.dart';
import 'f0922_elementary_ca_rule_108_variants.dart';
import 'f0922_elementary_ca_rule_108_metadata.dart';

/// Elementary CA Rule 108 — Cellular & Stochastic.
class F0922ElementaryCaRule108 extends CellularModule {
  F0922ElementaryCaRule108()
      : super(
          id: 'f0922_elementary_ca_rule_108',
          shader: 'shaders/f0922_elementary_ca_rule_108_gpu.frag',
        );

  @override
  F0922ElementaryCaRule108Metadata get metadata => F0922ElementaryCaRule108Metadata.instance;

  @override
  List<F0922ElementaryCaRule108Preset> get presets => F0922ElementaryCaRule108Presets.all;

  @override
  List<F0922ElementaryCaRule108Variant> get variants => F0922ElementaryCaRule108Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
