// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0937_elementary_ca_rule_146_presets.dart';
import 'f0937_elementary_ca_rule_146_variants.dart';
import 'f0937_elementary_ca_rule_146_metadata.dart';

/// Elementary CA Rule 146 — Cellular & Stochastic.
class F0937ElementaryCaRule146 extends CellularModule {
  F0937ElementaryCaRule146()
      : super(
          id: 'f0937_elementary_ca_rule_146',
          shader: 'shaders/f0937_elementary_ca_rule_146_gpu.frag',
        );

  @override
  F0937ElementaryCaRule146Metadata get metadata => F0937ElementaryCaRule146Metadata.instance;

  @override
  List<F0937ElementaryCaRule146Preset> get presets => F0937ElementaryCaRule146Presets.all;

  @override
  List<F0937ElementaryCaRule146Variant> get variants => F0937ElementaryCaRule146Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
