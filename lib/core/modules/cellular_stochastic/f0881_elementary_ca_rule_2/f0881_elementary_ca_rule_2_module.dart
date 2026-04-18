// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0881_elementary_ca_rule_2_presets.dart';
import 'f0881_elementary_ca_rule_2_variants.dart';
import 'f0881_elementary_ca_rule_2_metadata.dart';

/// Elementary CA Rule 2 — Cellular & Stochastic.
class F0881ElementaryCaRule2 extends CellularModule {
  F0881ElementaryCaRule2()
      : super(
          id: 'f0881_elementary_ca_rule_2',
          shader: 'shaders/f0881_elementary_ca_rule_2_gpu.frag',
        );

  @override
  F0881ElementaryCaRule2Metadata get metadata => F0881ElementaryCaRule2Metadata.instance;

  @override
  List<F0881ElementaryCaRule2Preset> get presets => F0881ElementaryCaRule2Presets.all;

  @override
  List<F0881ElementaryCaRule2Variant> get variants => F0881ElementaryCaRule2Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
