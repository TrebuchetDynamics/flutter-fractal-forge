// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0910_elementary_ca_rule_76_presets.dart';
import 'f0910_elementary_ca_rule_76_variants.dart';
import 'f0910_elementary_ca_rule_76_metadata.dart';

/// Elementary CA Rule 76 — Cellular & Stochastic.
class F0910ElementaryCaRule76 extends CellularModule {
  F0910ElementaryCaRule76()
      : super(
          id: 'f0910_elementary_ca_rule_76',
          shader: 'shaders/f0910_elementary_ca_rule_76_gpu.frag',
        );

  @override
  F0910ElementaryCaRule76Metadata get metadata => F0910ElementaryCaRule76Metadata.instance;

  @override
  List<F0910ElementaryCaRule76Preset> get presets => F0910ElementaryCaRule76Presets.all;

  @override
  List<F0910ElementaryCaRule76Variant> get variants => F0910ElementaryCaRule76Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
