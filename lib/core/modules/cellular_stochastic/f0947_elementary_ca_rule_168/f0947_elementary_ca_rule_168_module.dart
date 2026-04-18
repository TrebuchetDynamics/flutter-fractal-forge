// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0947_elementary_ca_rule_168_presets.dart';
import 'f0947_elementary_ca_rule_168_variants.dart';
import 'f0947_elementary_ca_rule_168_metadata.dart';

/// Elementary CA Rule 168 — Cellular & Stochastic.
class F0947ElementaryCaRule168 extends CellularModule {
  F0947ElementaryCaRule168()
      : super(
          id: 'f0947_elementary_ca_rule_168',
          shader: 'shaders/f0947_elementary_ca_rule_168_gpu.frag',
        );

  @override
  F0947ElementaryCaRule168Metadata get metadata => F0947ElementaryCaRule168Metadata.instance;

  @override
  List<F0947ElementaryCaRule168Preset> get presets => F0947ElementaryCaRule168Presets.all;

  @override
  List<F0947ElementaryCaRule168Variant> get variants => F0947ElementaryCaRule168Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
