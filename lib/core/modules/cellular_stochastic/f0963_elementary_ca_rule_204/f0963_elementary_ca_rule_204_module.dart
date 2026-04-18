// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0963_elementary_ca_rule_204_presets.dart';
import 'f0963_elementary_ca_rule_204_variants.dart';
import 'f0963_elementary_ca_rule_204_metadata.dart';

/// Elementary CA Rule 204 — Cellular & Stochastic.
class F0963ElementaryCaRule204 extends CellularModule {
  F0963ElementaryCaRule204()
      : super(
          id: 'f0963_elementary_ca_rule_204',
          shader: 'shaders/f0963_elementary_ca_rule_204_gpu.frag',
        );

  @override
  F0963ElementaryCaRule204Metadata get metadata => F0963ElementaryCaRule204Metadata.instance;

  @override
  List<F0963ElementaryCaRule204Preset> get presets => F0963ElementaryCaRule204Presets.all;

  @override
  List<F0963ElementaryCaRule204Variant> get variants => F0963ElementaryCaRule204Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
