// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0942_elementary_ca_rule_158_presets.dart';
import 'f0942_elementary_ca_rule_158_variants.dart';
import 'f0942_elementary_ca_rule_158_metadata.dart';

/// Elementary CA Rule 158 — Cellular & Stochastic.
class F0942ElementaryCaRule158 extends CellularModule {
  F0942ElementaryCaRule158()
      : super(
          id: 'f0942_elementary_ca_rule_158',
          shader: 'shaders/f0942_elementary_ca_rule_158_gpu.frag',
        );

  @override
  F0942ElementaryCaRule158Metadata get metadata => F0942ElementaryCaRule158Metadata.instance;

  @override
  List<F0942ElementaryCaRule158Preset> get presets => F0942ElementaryCaRule158Presets.all;

  @override
  List<F0942ElementaryCaRule158Variant> get variants => F0942ElementaryCaRule158Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
