// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0948_elementary_ca_rule_170_presets.dart';
import 'f0948_elementary_ca_rule_170_variants.dart';
import 'f0948_elementary_ca_rule_170_metadata.dart';

/// Elementary CA Rule 170 — Cellular & Stochastic.
class F0948ElementaryCaRule170 extends CellularModule {
  F0948ElementaryCaRule170()
      : super(
          id: 'f0948_elementary_ca_rule_170',
          shader: 'shaders/f0948_elementary_ca_rule_170_gpu.frag',
        );

  @override
  F0948ElementaryCaRule170Metadata get metadata => F0948ElementaryCaRule170Metadata.instance;

  @override
  List<F0948ElementaryCaRule170Preset> get presets => F0948ElementaryCaRule170Presets.all;

  @override
  List<F0948ElementaryCaRule170Variant> get variants => F0948ElementaryCaRule170Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
