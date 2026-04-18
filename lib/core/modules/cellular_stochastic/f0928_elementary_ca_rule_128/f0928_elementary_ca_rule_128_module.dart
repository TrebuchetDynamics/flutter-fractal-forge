// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0928_elementary_ca_rule_128_presets.dart';
import 'f0928_elementary_ca_rule_128_variants.dart';
import 'f0928_elementary_ca_rule_128_metadata.dart';

/// Elementary CA Rule 128 — Cellular & Stochastic.
class F0928ElementaryCaRule128 extends CellularModule {
  F0928ElementaryCaRule128()
      : super(
          id: 'f0928_elementary_ca_rule_128',
          shader: 'shaders/f0928_elementary_ca_rule_128_gpu.frag',
        );

  @override
  F0928ElementaryCaRule128Metadata get metadata => F0928ElementaryCaRule128Metadata.instance;

  @override
  List<F0928ElementaryCaRule128Preset> get presets => F0928ElementaryCaRule128Presets.all;

  @override
  List<F0928ElementaryCaRule128Variant> get variants => F0928ElementaryCaRule128Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
