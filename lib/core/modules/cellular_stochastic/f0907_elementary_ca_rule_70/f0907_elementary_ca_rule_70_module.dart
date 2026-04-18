// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0907_elementary_ca_rule_70_presets.dart';
import 'f0907_elementary_ca_rule_70_variants.dart';
import 'f0907_elementary_ca_rule_70_metadata.dart';

/// Elementary CA Rule 70 — Cellular & Stochastic.
class F0907ElementaryCaRule70 extends CellularModule {
  F0907ElementaryCaRule70()
      : super(
          id: 'f0907_elementary_ca_rule_70',
          shader: 'shaders/f0907_elementary_ca_rule_70_gpu.frag',
        );

  @override
  F0907ElementaryCaRule70Metadata get metadata => F0907ElementaryCaRule70Metadata.instance;

  @override
  List<F0907ElementaryCaRule70Preset> get presets => F0907ElementaryCaRule70Presets.all;

  @override
  List<F0907ElementaryCaRule70Variant> get variants => F0907ElementaryCaRule70Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
