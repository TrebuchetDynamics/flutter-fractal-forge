// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0912_elementary_ca_rule_80_presets.dart';
import 'f0912_elementary_ca_rule_80_variants.dart';
import 'f0912_elementary_ca_rule_80_metadata.dart';

/// Elementary CA Rule 80 — Cellular & Stochastic.
class F0912ElementaryCaRule80 extends CellularModule {
  F0912ElementaryCaRule80()
      : super(
          id: 'f0912_elementary_ca_rule_80',
          shader: 'shaders/f0912_elementary_ca_rule_80_gpu.frag',
        );

  @override
  F0912ElementaryCaRule80Metadata get metadata => F0912ElementaryCaRule80Metadata.instance;

  @override
  List<F0912ElementaryCaRule80Preset> get presets => F0912ElementaryCaRule80Presets.all;

  @override
  List<F0912ElementaryCaRule80Variant> get variants => F0912ElementaryCaRule80Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
