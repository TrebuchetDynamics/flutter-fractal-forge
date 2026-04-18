// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0975_elementary_ca_rule_234_presets.dart';
import 'f0975_elementary_ca_rule_234_variants.dart';
import 'f0975_elementary_ca_rule_234_metadata.dart';

/// Elementary CA Rule 234 — Cellular & Stochastic.
class F0975ElementaryCaRule234 extends CellularModule {
  F0975ElementaryCaRule234()
      : super(
          id: 'f0975_elementary_ca_rule_234',
          shader: 'shaders/f0975_elementary_ca_rule_234_gpu.frag',
        );

  @override
  F0975ElementaryCaRule234Metadata get metadata => F0975ElementaryCaRule234Metadata.instance;

  @override
  List<F0975ElementaryCaRule234Preset> get presets => F0975ElementaryCaRule234Presets.all;

  @override
  List<F0975ElementaryCaRule234Variant> get variants => F0975ElementaryCaRule234Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
