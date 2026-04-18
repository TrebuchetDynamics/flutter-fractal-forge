// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0895_elementary_ca_rule_34_presets.dart';
import 'f0895_elementary_ca_rule_34_variants.dart';
import 'f0895_elementary_ca_rule_34_metadata.dart';

/// Elementary CA Rule 34 — Cellular & Stochastic.
class F0895ElementaryCaRule34 extends CellularModule {
  F0895ElementaryCaRule34()
      : super(
          id: 'f0895_elementary_ca_rule_34',
          shader: 'shaders/f0895_elementary_ca_rule_34_gpu.frag',
        );

  @override
  F0895ElementaryCaRule34Metadata get metadata => F0895ElementaryCaRule34Metadata.instance;

  @override
  List<F0895ElementaryCaRule34Preset> get presets => F0895ElementaryCaRule34Presets.all;

  @override
  List<F0895ElementaryCaRule34Variant> get variants => F0895ElementaryCaRule34Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
