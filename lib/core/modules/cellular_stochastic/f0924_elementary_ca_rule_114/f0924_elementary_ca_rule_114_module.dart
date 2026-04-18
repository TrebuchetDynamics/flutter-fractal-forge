// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0924_elementary_ca_rule_114_presets.dart';
import 'f0924_elementary_ca_rule_114_variants.dart';
import 'f0924_elementary_ca_rule_114_metadata.dart';

/// Elementary CA Rule 114 — Cellular & Stochastic.
class F0924ElementaryCaRule114 extends CellularModule {
  F0924ElementaryCaRule114()
      : super(
          id: 'f0924_elementary_ca_rule_114',
          shader: 'shaders/f0924_elementary_ca_rule_114_gpu.frag',
        );

  @override
  F0924ElementaryCaRule114Metadata get metadata => F0924ElementaryCaRule114Metadata.instance;

  @override
  List<F0924ElementaryCaRule114Preset> get presets => F0924ElementaryCaRule114Presets.all;

  @override
  List<F0924ElementaryCaRule114Variant> get variants => F0924ElementaryCaRule114Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
