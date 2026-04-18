// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0899_elementary_ca_rule_42_presets.dart';
import 'f0899_elementary_ca_rule_42_variants.dart';
import 'f0899_elementary_ca_rule_42_metadata.dart';

/// Elementary CA Rule 42 — Cellular & Stochastic.
class F0899ElementaryCaRule42 extends CellularModule {
  F0899ElementaryCaRule42()
      : super(
          id: 'f0899_elementary_ca_rule_42',
          shader: 'shaders/f0899_elementary_ca_rule_42_gpu.frag',
        );

  @override
  F0899ElementaryCaRule42Metadata get metadata => F0899ElementaryCaRule42Metadata.instance;

  @override
  List<F0899ElementaryCaRule42Preset> get presets => F0899ElementaryCaRule42Presets.all;

  @override
  List<F0899ElementaryCaRule42Variant> get variants => F0899ElementaryCaRule42Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
