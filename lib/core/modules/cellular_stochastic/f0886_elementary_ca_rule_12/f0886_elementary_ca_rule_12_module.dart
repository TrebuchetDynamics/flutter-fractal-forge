// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0886_elementary_ca_rule_12_presets.dart';
import 'f0886_elementary_ca_rule_12_variants.dart';
import 'f0886_elementary_ca_rule_12_metadata.dart';

/// Elementary CA Rule 12 — Cellular & Stochastic.
class F0886ElementaryCaRule12 extends CellularModule {
  F0886ElementaryCaRule12()
      : super(
          id: 'f0886_elementary_ca_rule_12',
          shader: 'shaders/f0886_elementary_ca_rule_12_gpu.frag',
        );

  @override
  F0886ElementaryCaRule12Metadata get metadata => F0886ElementaryCaRule12Metadata.instance;

  @override
  List<F0886ElementaryCaRule12Preset> get presets => F0886ElementaryCaRule12Presets.all;

  @override
  List<F0886ElementaryCaRule12Variant> get variants => F0886ElementaryCaRule12Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
