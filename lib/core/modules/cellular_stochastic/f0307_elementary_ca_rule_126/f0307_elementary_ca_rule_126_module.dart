// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0307_elementary_ca_rule_126_presets.dart';
import 'f0307_elementary_ca_rule_126_variants.dart';
import 'f0307_elementary_ca_rule_126_metadata.dart';

/// Elementary CA Rule 126 — Cellular & Stochastic.
class F0307ElementaryCaRule126 extends CellularModule {
  F0307ElementaryCaRule126()
      : super(
          id: 'f0307_elementary_ca_rule_126',
          shader: 'shaders/f0307_elementary_ca_rule_126_gpu.frag',
        );

  @override
  F0307ElementaryCaRule126Metadata get metadata => F0307ElementaryCaRule126Metadata.instance;

  @override
  List<F0307ElementaryCaRule126Preset> get presets => F0307ElementaryCaRule126Presets.all;

  @override
  List<F0307ElementaryCaRule126Variant> get variants => F0307ElementaryCaRule126Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
