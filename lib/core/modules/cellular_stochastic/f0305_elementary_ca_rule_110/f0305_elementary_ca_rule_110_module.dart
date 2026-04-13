// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0305_elementary_ca_rule_110_presets.dart';
import 'f0305_elementary_ca_rule_110_variants.dart';
import 'f0305_elementary_ca_rule_110_metadata.dart';

/// Elementary CA Rule 110 — Cellular & Stochastic.
class F0305ElementaryCaRule110 extends CellularModule {
  F0305ElementaryCaRule110()
      : super(
          id: 'f0305_elementary_ca_rule_110',
          shader: 'shaders/f0305_elementary_ca_rule_110_gpu.frag',
        );

  @override
  F0305ElementaryCaRule110Metadata get metadata => F0305ElementaryCaRule110Metadata.instance;

  @override
  List<F0305ElementaryCaRule110Preset> get presets => F0305ElementaryCaRule110Presets.all;

  @override
  List<F0305ElementaryCaRule110Variant> get variants => F0305ElementaryCaRule110Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
