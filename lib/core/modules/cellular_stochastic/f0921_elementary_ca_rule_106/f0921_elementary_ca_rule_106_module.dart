// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0921_elementary_ca_rule_106_presets.dart';
import 'f0921_elementary_ca_rule_106_variants.dart';
import 'f0921_elementary_ca_rule_106_metadata.dart';

/// Elementary CA Rule 106 — Cellular & Stochastic.
class F0921ElementaryCaRule106 extends CellularModule {
  F0921ElementaryCaRule106()
      : super(
          id: 'f0921_elementary_ca_rule_106',
          shader: 'shaders/f0921_elementary_ca_rule_106_gpu.frag',
        );

  @override
  F0921ElementaryCaRule106Metadata get metadata => F0921ElementaryCaRule106Metadata.instance;

  @override
  List<F0921ElementaryCaRule106Preset> get presets => F0921ElementaryCaRule106Presets.all;

  @override
  List<F0921ElementaryCaRule106Variant> get variants => F0921ElementaryCaRule106Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
