// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0927_elementary_ca_rule_124_presets.dart';
import 'f0927_elementary_ca_rule_124_variants.dart';
import 'f0927_elementary_ca_rule_124_metadata.dart';

/// Elementary CA Rule 124 — Cellular & Stochastic.
class F0927ElementaryCaRule124 extends CellularModule {
  F0927ElementaryCaRule124()
      : super(
          id: 'f0927_elementary_ca_rule_124',
          shader: 'shaders/f0927_elementary_ca_rule_124_gpu.frag',
        );

  @override
  F0927ElementaryCaRule124Metadata get metadata => F0927ElementaryCaRule124Metadata.instance;

  @override
  List<F0927ElementaryCaRule124Preset> get presets => F0927ElementaryCaRule124Presets.all;

  @override
  List<F0927ElementaryCaRule124Variant> get variants => F0927ElementaryCaRule124Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
