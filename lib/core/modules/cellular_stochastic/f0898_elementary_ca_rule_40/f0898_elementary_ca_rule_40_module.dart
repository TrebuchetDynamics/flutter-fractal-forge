// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0898_elementary_ca_rule_40_presets.dart';
import 'f0898_elementary_ca_rule_40_variants.dart';
import 'f0898_elementary_ca_rule_40_metadata.dart';

/// Elementary CA Rule 40 — Cellular & Stochastic.
class F0898ElementaryCaRule40 extends CellularModule {
  F0898ElementaryCaRule40()
      : super(
          id: 'f0898_elementary_ca_rule_40',
          shader: 'shaders/f0898_elementary_ca_rule_40_gpu.frag',
        );

  @override
  F0898ElementaryCaRule40Metadata get metadata => F0898ElementaryCaRule40Metadata.instance;

  @override
  List<F0898ElementaryCaRule40Preset> get presets => F0898ElementaryCaRule40Presets.all;

  @override
  List<F0898ElementaryCaRule40Variant> get variants => F0898ElementaryCaRule40Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
