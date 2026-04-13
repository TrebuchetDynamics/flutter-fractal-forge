// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0311_elementary_ca_rule_22_presets.dart';
import 'f0311_elementary_ca_rule_22_variants.dart';
import 'f0311_elementary_ca_rule_22_metadata.dart';

/// Elementary CA Rule 22 — Cellular & Stochastic.
class F0311ElementaryCaRule22 extends CellularModule {
  F0311ElementaryCaRule22()
      : super(
          id: 'f0311_elementary_ca_rule_22',
          shader: 'shaders/f0311_elementary_ca_rule_22_gpu.frag',
        );

  @override
  F0311ElementaryCaRule22Metadata get metadata => F0311ElementaryCaRule22Metadata.instance;

  @override
  List<F0311ElementaryCaRule22Preset> get presets => F0311ElementaryCaRule22Presets.all;

  @override
  List<F0311ElementaryCaRule22Variant> get variants => F0311ElementaryCaRule22Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
