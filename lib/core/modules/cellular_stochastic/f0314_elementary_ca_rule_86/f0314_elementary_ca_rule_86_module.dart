// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0314_elementary_ca_rule_86_presets.dart';
import 'f0314_elementary_ca_rule_86_variants.dart';
import 'f0314_elementary_ca_rule_86_metadata.dart';

/// Elementary CA Rule 86 — Cellular & Stochastic.
class F0314ElementaryCaRule86 extends CellularModule {
  F0314ElementaryCaRule86()
      : super(
          id: 'f0314_elementary_ca_rule_86',
          shader: 'shaders/f0314_elementary_ca_rule_86_gpu.frag',
        );

  @override
  F0314ElementaryCaRule86Metadata get metadata => F0314ElementaryCaRule86Metadata.instance;

  @override
  List<F0314ElementaryCaRule86Preset> get presets => F0314ElementaryCaRule86Presets.all;

  @override
  List<F0314ElementaryCaRule86Variant> get variants => F0314ElementaryCaRule86Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
