// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0306_elementary_ca_rule_122_presets.dart';
import 'f0306_elementary_ca_rule_122_variants.dart';
import 'f0306_elementary_ca_rule_122_metadata.dart';

/// Elementary CA Rule 122 — Cellular & Stochastic.
class F0306ElementaryCaRule122 extends CellularModule {
  F0306ElementaryCaRule122()
      : super(
          id: 'f0306_elementary_ca_rule_122',
          shader: 'shaders/f0306_elementary_ca_rule_122_gpu.frag',
        );

  @override
  F0306ElementaryCaRule122Metadata get metadata => F0306ElementaryCaRule122Metadata.instance;

  @override
  List<F0306ElementaryCaRule122Preset> get presets => F0306ElementaryCaRule122Presets.all;

  @override
  List<F0306ElementaryCaRule122Variant> get variants => F0306ElementaryCaRule122Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
