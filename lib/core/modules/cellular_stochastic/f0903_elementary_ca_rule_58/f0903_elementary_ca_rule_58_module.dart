// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0903_elementary_ca_rule_58_presets.dart';
import 'f0903_elementary_ca_rule_58_variants.dart';
import 'f0903_elementary_ca_rule_58_metadata.dart';

/// Elementary CA Rule 58 — Cellular & Stochastic.
class F0903ElementaryCaRule58 extends CellularModule {
  F0903ElementaryCaRule58()
      : super(
          id: 'f0903_elementary_ca_rule_58',
          shader: 'shaders/f0903_elementary_ca_rule_58_gpu.frag',
        );

  @override
  F0903ElementaryCaRule58Metadata get metadata => F0903ElementaryCaRule58Metadata.instance;

  @override
  List<F0903ElementaryCaRule58Preset> get presets => F0903ElementaryCaRule58Presets.all;

  @override
  List<F0903ElementaryCaRule58Variant> get variants => F0903ElementaryCaRule58Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
