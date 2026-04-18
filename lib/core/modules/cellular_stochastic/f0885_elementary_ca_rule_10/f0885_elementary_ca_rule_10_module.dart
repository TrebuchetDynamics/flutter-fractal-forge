// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0885_elementary_ca_rule_10_presets.dart';
import 'f0885_elementary_ca_rule_10_variants.dart';
import 'f0885_elementary_ca_rule_10_metadata.dart';

/// Elementary CA Rule 10 — Cellular & Stochastic.
class F0885ElementaryCaRule10 extends CellularModule {
  F0885ElementaryCaRule10()
      : super(
          id: 'f0885_elementary_ca_rule_10',
          shader: 'shaders/f0885_elementary_ca_rule_10_gpu.frag',
        );

  @override
  F0885ElementaryCaRule10Metadata get metadata => F0885ElementaryCaRule10Metadata.instance;

  @override
  List<F0885ElementaryCaRule10Preset> get presets => F0885ElementaryCaRule10Presets.all;

  @override
  List<F0885ElementaryCaRule10Variant> get variants => F0885ElementaryCaRule10Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
