// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0889_elementary_ca_rule_18_presets.dart';
import 'f0889_elementary_ca_rule_18_variants.dart';
import 'f0889_elementary_ca_rule_18_metadata.dart';

/// Elementary CA Rule 18 — Cellular & Stochastic.
class F0889ElementaryCaRule18 extends CellularModule {
  F0889ElementaryCaRule18()
      : super(
          id: 'f0889_elementary_ca_rule_18',
          shader: 'shaders/f0889_elementary_ca_rule_18_gpu.frag',
        );

  @override
  F0889ElementaryCaRule18Metadata get metadata => F0889ElementaryCaRule18Metadata.instance;

  @override
  List<F0889ElementaryCaRule18Preset> get presets => F0889ElementaryCaRule18Presets.all;

  @override
  List<F0889ElementaryCaRule18Variant> get variants => F0889ElementaryCaRule18Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
