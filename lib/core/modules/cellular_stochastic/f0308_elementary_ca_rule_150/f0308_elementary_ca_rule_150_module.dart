// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0308_elementary_ca_rule_150_presets.dart';
import 'f0308_elementary_ca_rule_150_variants.dart';
import 'f0308_elementary_ca_rule_150_metadata.dart';

/// Elementary CA Rule 150 — Cellular & Stochastic.
class F0308ElementaryCaRule150 extends CellularModule {
  F0308ElementaryCaRule150()
      : super(
          id: 'f0308_elementary_ca_rule_150',
          shader: 'shaders/f0308_elementary_ca_rule_150_gpu.frag',
        );

  @override
  F0308ElementaryCaRule150Metadata get metadata => F0308ElementaryCaRule150Metadata.instance;

  @override
  List<F0308ElementaryCaRule150Preset> get presets => F0308ElementaryCaRule150Presets.all;

  @override
  List<F0308ElementaryCaRule150Variant> get variants => F0308ElementaryCaRule150Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
