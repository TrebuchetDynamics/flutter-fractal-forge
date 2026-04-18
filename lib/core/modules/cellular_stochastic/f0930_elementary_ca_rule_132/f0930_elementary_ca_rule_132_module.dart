// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0930_elementary_ca_rule_132_presets.dart';
import 'f0930_elementary_ca_rule_132_variants.dart';
import 'f0930_elementary_ca_rule_132_metadata.dart';

/// Elementary CA Rule 132 — Cellular & Stochastic.
class F0930ElementaryCaRule132 extends CellularModule {
  F0930ElementaryCaRule132()
      : super(
          id: 'f0930_elementary_ca_rule_132',
          shader: 'shaders/f0930_elementary_ca_rule_132_gpu.frag',
        );

  @override
  F0930ElementaryCaRule132Metadata get metadata => F0930ElementaryCaRule132Metadata.instance;

  @override
  List<F0930ElementaryCaRule132Preset> get presets => F0930ElementaryCaRule132Presets.all;

  @override
  List<F0930ElementaryCaRule132Variant> get variants => F0930ElementaryCaRule132Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
