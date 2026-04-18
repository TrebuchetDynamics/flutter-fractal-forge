// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0888_elementary_ca_rule_16_presets.dart';
import 'f0888_elementary_ca_rule_16_variants.dart';
import 'f0888_elementary_ca_rule_16_metadata.dart';

/// Elementary CA Rule 16 — Cellular & Stochastic.
class F0888ElementaryCaRule16 extends CellularModule {
  F0888ElementaryCaRule16()
      : super(
          id: 'f0888_elementary_ca_rule_16',
          shader: 'shaders/f0888_elementary_ca_rule_16_gpu.frag',
        );

  @override
  F0888ElementaryCaRule16Metadata get metadata => F0888ElementaryCaRule16Metadata.instance;

  @override
  List<F0888ElementaryCaRule16Preset> get presets => F0888ElementaryCaRule16Presets.all;

  @override
  List<F0888ElementaryCaRule16Variant> get variants => F0888ElementaryCaRule16Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
