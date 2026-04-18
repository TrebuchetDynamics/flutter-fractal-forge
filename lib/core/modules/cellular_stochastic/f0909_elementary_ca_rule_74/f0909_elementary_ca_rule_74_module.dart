// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0909_elementary_ca_rule_74_presets.dart';
import 'f0909_elementary_ca_rule_74_variants.dart';
import 'f0909_elementary_ca_rule_74_metadata.dart';

/// Elementary CA Rule 74 — Cellular & Stochastic.
class F0909ElementaryCaRule74 extends CellularModule {
  F0909ElementaryCaRule74()
      : super(
          id: 'f0909_elementary_ca_rule_74',
          shader: 'shaders/f0909_elementary_ca_rule_74_gpu.frag',
        );

  @override
  F0909ElementaryCaRule74Metadata get metadata => F0909ElementaryCaRule74Metadata.instance;

  @override
  List<F0909ElementaryCaRule74Preset> get presets => F0909ElementaryCaRule74Presets.all;

  @override
  List<F0909ElementaryCaRule74Variant> get variants => F0909ElementaryCaRule74Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
