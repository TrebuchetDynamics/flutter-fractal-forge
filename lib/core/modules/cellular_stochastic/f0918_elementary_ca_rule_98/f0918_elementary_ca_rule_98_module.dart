// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0918_elementary_ca_rule_98_presets.dart';
import 'f0918_elementary_ca_rule_98_variants.dart';
import 'f0918_elementary_ca_rule_98_metadata.dart';

/// Elementary CA Rule 98 — Cellular & Stochastic.
class F0918ElementaryCaRule98 extends CellularModule {
  F0918ElementaryCaRule98()
      : super(
          id: 'f0918_elementary_ca_rule_98',
          shader: 'shaders/f0918_elementary_ca_rule_98_gpu.frag',
        );

  @override
  F0918ElementaryCaRule98Metadata get metadata => F0918ElementaryCaRule98Metadata.instance;

  @override
  List<F0918ElementaryCaRule98Preset> get presets => F0918ElementaryCaRule98Presets.all;

  @override
  List<F0918ElementaryCaRule98Variant> get variants => F0918ElementaryCaRule98Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
