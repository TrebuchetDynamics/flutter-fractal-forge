// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0303_elementary_ca_rule_94_presets.dart';
import 'f0303_elementary_ca_rule_94_variants.dart';
import 'f0303_elementary_ca_rule_94_metadata.dart';

/// Elementary CA Rule 94 — Cellular & Stochastic.
class F0303ElementaryCaRule94 extends CellularModule {
  F0303ElementaryCaRule94()
      : super(
          id: 'f0303_elementary_ca_rule_94',
          shader: 'shaders/f0303_elementary_ca_rule_94_gpu.frag',
        );

  @override
  F0303ElementaryCaRule94Metadata get metadata => F0303ElementaryCaRule94Metadata.instance;

  @override
  List<F0303ElementaryCaRule94Preset> get presets => F0303ElementaryCaRule94Presets.all;

  @override
  List<F0303ElementaryCaRule94Variant> get variants => F0303ElementaryCaRule94Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
