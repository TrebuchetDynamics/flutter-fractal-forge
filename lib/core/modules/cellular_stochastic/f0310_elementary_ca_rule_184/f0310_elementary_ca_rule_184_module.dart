// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0310_elementary_ca_rule_184_presets.dart';
import 'f0310_elementary_ca_rule_184_variants.dart';
import 'f0310_elementary_ca_rule_184_metadata.dart';

/// Elementary CA Rule 184 — Cellular & Stochastic.
class F0310ElementaryCaRule184 extends CellularModule {
  F0310ElementaryCaRule184()
      : super(
          id: 'f0310_elementary_ca_rule_184',
          shader: 'shaders/f0310_elementary_ca_rule_184_gpu.frag',
        );

  @override
  F0310ElementaryCaRule184Metadata get metadata => F0310ElementaryCaRule184Metadata.instance;

  @override
  List<F0310ElementaryCaRule184Preset> get presets => F0310ElementaryCaRule184Presets.all;

  @override
  List<F0310ElementaryCaRule184Variant> get variants => F0310ElementaryCaRule184Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
