// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0962_elementary_ca_rule_202_presets.dart';
import 'f0962_elementary_ca_rule_202_variants.dart';
import 'f0962_elementary_ca_rule_202_metadata.dart';

/// Elementary CA Rule 202 — Cellular & Stochastic.
class F0962ElementaryCaRule202 extends CellularModule {
  F0962ElementaryCaRule202()
      : super(
          id: 'f0962_elementary_ca_rule_202',
          shader: 'shaders/f0962_elementary_ca_rule_202_gpu.frag',
        );

  @override
  F0962ElementaryCaRule202Metadata get metadata => F0962ElementaryCaRule202Metadata.instance;

  @override
  List<F0962ElementaryCaRule202Preset> get presets => F0962ElementaryCaRule202Presets.all;

  @override
  List<F0962ElementaryCaRule202Variant> get variants => F0962ElementaryCaRule202Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
