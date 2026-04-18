// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0972_elementary_ca_rule_226_presets.dart';
import 'f0972_elementary_ca_rule_226_variants.dart';
import 'f0972_elementary_ca_rule_226_metadata.dart';

/// Elementary CA Rule 226 — Cellular & Stochastic.
class F0972ElementaryCaRule226 extends CellularModule {
  F0972ElementaryCaRule226()
      : super(
          id: 'f0972_elementary_ca_rule_226',
          shader: 'shaders/f0972_elementary_ca_rule_226_gpu.frag',
        );

  @override
  F0972ElementaryCaRule226Metadata get metadata => F0972ElementaryCaRule226Metadata.instance;

  @override
  List<F0972ElementaryCaRule226Preset> get presets => F0972ElementaryCaRule226Presets.all;

  @override
  List<F0972ElementaryCaRule226Variant> get variants => F0972ElementaryCaRule226Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
