// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0309_elementary_ca_rule_182_presets.dart';
import 'f0309_elementary_ca_rule_182_variants.dart';
import 'f0309_elementary_ca_rule_182_metadata.dart';

/// Elementary CA Rule 182 — Cellular & Stochastic.
class F0309ElementaryCaRule182 extends CellularModule {
  F0309ElementaryCaRule182()
      : super(
          id: 'f0309_elementary_ca_rule_182',
          shader: 'shaders/f0309_elementary_ca_rule_182_gpu.frag',
        );

  @override
  F0309ElementaryCaRule182Metadata get metadata => F0309ElementaryCaRule182Metadata.instance;

  @override
  List<F0309ElementaryCaRule182Preset> get presets => F0309ElementaryCaRule182Presets.all;

  @override
  List<F0309ElementaryCaRule182Variant> get variants => F0309ElementaryCaRule182Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
