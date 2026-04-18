// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0951_elementary_ca_rule_176_presets.dart';
import 'f0951_elementary_ca_rule_176_variants.dart';
import 'f0951_elementary_ca_rule_176_metadata.dart';

/// Elementary CA Rule 176 — Cellular & Stochastic.
class F0951ElementaryCaRule176 extends CellularModule {
  F0951ElementaryCaRule176()
      : super(
          id: 'f0951_elementary_ca_rule_176',
          shader: 'shaders/f0951_elementary_ca_rule_176_gpu.frag',
        );

  @override
  F0951ElementaryCaRule176Metadata get metadata => F0951ElementaryCaRule176Metadata.instance;

  @override
  List<F0951ElementaryCaRule176Preset> get presets => F0951ElementaryCaRule176Presets.all;

  @override
  List<F0951ElementaryCaRule176Variant> get variants => F0951ElementaryCaRule176Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
