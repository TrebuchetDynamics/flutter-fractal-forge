// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0952_elementary_ca_rule_178_presets.dart';
import 'f0952_elementary_ca_rule_178_variants.dart';
import 'f0952_elementary_ca_rule_178_metadata.dart';

/// Elementary CA Rule 178 — Cellular & Stochastic.
class F0952ElementaryCaRule178 extends CellularModule {
  F0952ElementaryCaRule178()
      : super(
          id: 'f0952_elementary_ca_rule_178',
          shader: 'shaders/f0952_elementary_ca_rule_178_gpu.frag',
        );

  @override
  F0952ElementaryCaRule178Metadata get metadata => F0952ElementaryCaRule178Metadata.instance;

  @override
  List<F0952ElementaryCaRule178Preset> get presets => F0952ElementaryCaRule178Presets.all;

  @override
  List<F0952ElementaryCaRule178Variant> get variants => F0952ElementaryCaRule178Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
