// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0883_elementary_ca_rule_6_presets.dart';
import 'f0883_elementary_ca_rule_6_variants.dart';
import 'f0883_elementary_ca_rule_6_metadata.dart';

/// Elementary CA Rule 6 — Cellular & Stochastic.
class F0883ElementaryCaRule6 extends CellularModule {
  F0883ElementaryCaRule6()
      : super(
          id: 'f0883_elementary_ca_rule_6',
          shader: 'shaders/f0883_elementary_ca_rule_6_gpu.frag',
        );

  @override
  F0883ElementaryCaRule6Metadata get metadata => F0883ElementaryCaRule6Metadata.instance;

  @override
  List<F0883ElementaryCaRule6Preset> get presets => F0883ElementaryCaRule6Presets.all;

  @override
  List<F0883ElementaryCaRule6Variant> get variants => F0883ElementaryCaRule6Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
