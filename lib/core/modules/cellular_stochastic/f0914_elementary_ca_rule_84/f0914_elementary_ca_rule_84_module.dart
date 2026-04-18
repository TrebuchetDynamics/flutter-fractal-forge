// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0914_elementary_ca_rule_84_presets.dart';
import 'f0914_elementary_ca_rule_84_variants.dart';
import 'f0914_elementary_ca_rule_84_metadata.dart';

/// Elementary CA Rule 84 — Cellular & Stochastic.
class F0914ElementaryCaRule84 extends CellularModule {
  F0914ElementaryCaRule84()
      : super(
          id: 'f0914_elementary_ca_rule_84',
          shader: 'shaders/f0914_elementary_ca_rule_84_gpu.frag',
        );

  @override
  F0914ElementaryCaRule84Metadata get metadata => F0914ElementaryCaRule84Metadata.instance;

  @override
  List<F0914ElementaryCaRule84Preset> get presets => F0914ElementaryCaRule84Presets.all;

  @override
  List<F0914ElementaryCaRule84Variant> get variants => F0914ElementaryCaRule84Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
