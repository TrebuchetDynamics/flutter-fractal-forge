// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0938_elementary_ca_rule_148_presets.dart';
import 'f0938_elementary_ca_rule_148_variants.dart';
import 'f0938_elementary_ca_rule_148_metadata.dart';

/// Elementary CA Rule 148 — Cellular & Stochastic.
class F0938ElementaryCaRule148 extends CellularModule {
  F0938ElementaryCaRule148()
      : super(
          id: 'f0938_elementary_ca_rule_148',
          shader: 'shaders/f0938_elementary_ca_rule_148_gpu.frag',
        );

  @override
  F0938ElementaryCaRule148Metadata get metadata => F0938ElementaryCaRule148Metadata.instance;

  @override
  List<F0938ElementaryCaRule148Preset> get presets => F0938ElementaryCaRule148Presets.all;

  @override
  List<F0938ElementaryCaRule148Variant> get variants => F0938ElementaryCaRule148Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
