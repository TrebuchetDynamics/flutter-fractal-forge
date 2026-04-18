// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0934_elementary_ca_rule_140_presets.dart';
import 'f0934_elementary_ca_rule_140_variants.dart';
import 'f0934_elementary_ca_rule_140_metadata.dart';

/// Elementary CA Rule 140 — Cellular & Stochastic.
class F0934ElementaryCaRule140 extends CellularModule {
  F0934ElementaryCaRule140()
      : super(
          id: 'f0934_elementary_ca_rule_140',
          shader: 'shaders/f0934_elementary_ca_rule_140_gpu.frag',
        );

  @override
  F0934ElementaryCaRule140Metadata get metadata => F0934ElementaryCaRule140Metadata.instance;

  @override
  List<F0934ElementaryCaRule140Preset> get presets => F0934ElementaryCaRule140Presets.all;

  @override
  List<F0934ElementaryCaRule140Variant> get variants => F0934ElementaryCaRule140Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
