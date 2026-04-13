// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0315_elementary_ca_rule_105_presets.dart';
import 'f0315_elementary_ca_rule_105_variants.dart';
import 'f0315_elementary_ca_rule_105_metadata.dart';

/// Elementary CA Rule 105 — Cellular & Stochastic.
class F0315ElementaryCaRule105 extends CellularModule {
  F0315ElementaryCaRule105()
      : super(
          id: 'f0315_elementary_ca_rule_105',
          shader: 'shaders/f0315_elementary_ca_rule_105_gpu.frag',
        );

  @override
  F0315ElementaryCaRule105Metadata get metadata => F0315ElementaryCaRule105Metadata.instance;

  @override
  List<F0315ElementaryCaRule105Preset> get presets => F0315ElementaryCaRule105Presets.all;

  @override
  List<F0315ElementaryCaRule105Variant> get variants => F0315ElementaryCaRule105Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
