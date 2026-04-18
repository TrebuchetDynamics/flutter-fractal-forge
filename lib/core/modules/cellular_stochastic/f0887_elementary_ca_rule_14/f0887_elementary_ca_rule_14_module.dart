// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0887_elementary_ca_rule_14_presets.dart';
import 'f0887_elementary_ca_rule_14_variants.dart';
import 'f0887_elementary_ca_rule_14_metadata.dart';

/// Elementary CA Rule 14 — Cellular & Stochastic.
class F0887ElementaryCaRule14 extends CellularModule {
  F0887ElementaryCaRule14()
      : super(
          id: 'f0887_elementary_ca_rule_14',
          shader: 'shaders/f0887_elementary_ca_rule_14_gpu.frag',
        );

  @override
  F0887ElementaryCaRule14Metadata get metadata => F0887ElementaryCaRule14Metadata.instance;

  @override
  List<F0887ElementaryCaRule14Preset> get presets => F0887ElementaryCaRule14Presets.all;

  @override
  List<F0887ElementaryCaRule14Variant> get variants => F0887ElementaryCaRule14Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
