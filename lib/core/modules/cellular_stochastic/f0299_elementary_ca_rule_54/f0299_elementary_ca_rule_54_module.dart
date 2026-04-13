// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0299_elementary_ca_rule_54_presets.dart';
import 'f0299_elementary_ca_rule_54_variants.dart';
import 'f0299_elementary_ca_rule_54_metadata.dart';

/// Elementary CA Rule 54 — Cellular & Stochastic.
class F0299ElementaryCaRule54 extends CellularModule {
  F0299ElementaryCaRule54()
      : super(
          id: 'f0299_elementary_ca_rule_54',
          shader: 'shaders/f0299_elementary_ca_rule_54_gpu.frag',
        );

  @override
  F0299ElementaryCaRule54Metadata get metadata => F0299ElementaryCaRule54Metadata.instance;

  @override
  List<F0299ElementaryCaRule54Preset> get presets => F0299ElementaryCaRule54Presets.all;

  @override
  List<F0299ElementaryCaRule54Variant> get variants => F0299ElementaryCaRule54Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
