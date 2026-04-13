// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0302_elementary_ca_rule_90_presets.dart';
import 'f0302_elementary_ca_rule_90_variants.dart';
import 'f0302_elementary_ca_rule_90_metadata.dart';

/// Elementary CA Rule 90 — Cellular & Stochastic.
class F0302ElementaryCaRule90 extends CellularModule {
  F0302ElementaryCaRule90()
      : super(
          id: 'f0302_elementary_ca_rule_90',
          shader: 'shaders/f0302_elementary_ca_rule_90_gpu.frag',
        );

  @override
  F0302ElementaryCaRule90Metadata get metadata => F0302ElementaryCaRule90Metadata.instance;

  @override
  List<F0302ElementaryCaRule90Preset> get presets => F0302ElementaryCaRule90Presets.all;

  @override
  List<F0302ElementaryCaRule90Variant> get variants => F0302ElementaryCaRule90Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
