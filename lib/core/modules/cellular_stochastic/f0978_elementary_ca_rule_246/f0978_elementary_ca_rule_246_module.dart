// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0978_elementary_ca_rule_246_presets.dart';
import 'f0978_elementary_ca_rule_246_variants.dart';
import 'f0978_elementary_ca_rule_246_metadata.dart';

/// Elementary CA Rule 246 — Cellular & Stochastic.
class F0978ElementaryCaRule246 extends CellularModule {
  F0978ElementaryCaRule246()
      : super(
          id: 'f0978_elementary_ca_rule_246',
          shader: 'shaders/f0978_elementary_ca_rule_246_gpu.frag',
        );

  @override
  F0978ElementaryCaRule246Metadata get metadata => F0978ElementaryCaRule246Metadata.instance;

  @override
  List<F0978ElementaryCaRule246Preset> get presets => F0978ElementaryCaRule246Presets.all;

  @override
  List<F0978ElementaryCaRule246Variant> get variants => F0978ElementaryCaRule246Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
