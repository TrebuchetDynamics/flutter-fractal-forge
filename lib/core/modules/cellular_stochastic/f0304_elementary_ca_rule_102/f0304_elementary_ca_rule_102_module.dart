// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0304_elementary_ca_rule_102_presets.dart';
import 'f0304_elementary_ca_rule_102_variants.dart';
import 'f0304_elementary_ca_rule_102_metadata.dart';

/// Elementary CA Rule 102 — Cellular & Stochastic.
class F0304ElementaryCaRule102 extends CellularModule {
  F0304ElementaryCaRule102()
      : super(
          id: 'f0304_elementary_ca_rule_102',
          shader: 'shaders/f0304_elementary_ca_rule_102_gpu.frag',
        );

  @override
  F0304ElementaryCaRule102Metadata get metadata => F0304ElementaryCaRule102Metadata.instance;

  @override
  List<F0304ElementaryCaRule102Preset> get presets => F0304ElementaryCaRule102Presets.all;

  @override
  List<F0304ElementaryCaRule102Variant> get variants => F0304ElementaryCaRule102Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
