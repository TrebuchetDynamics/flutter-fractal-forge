// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0979_elementary_ca_rule_254_presets.dart';
import 'f0979_elementary_ca_rule_254_variants.dart';
import 'f0979_elementary_ca_rule_254_metadata.dart';

/// Elementary CA Rule 254 — Cellular & Stochastic.
class F0979ElementaryCaRule254 extends CellularModule {
  F0979ElementaryCaRule254()
      : super(
          id: 'f0979_elementary_ca_rule_254',
          shader: 'shaders/f0979_elementary_ca_rule_254_gpu.frag',
        );

  @override
  F0979ElementaryCaRule254Metadata get metadata => F0979ElementaryCaRule254Metadata.instance;

  @override
  List<F0979ElementaryCaRule254Preset> get presets => F0979ElementaryCaRule254Presets.all;

  @override
  List<F0979ElementaryCaRule254Variant> get variants => F0979ElementaryCaRule254Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
