// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0908_elementary_ca_rule_72_presets.dart';
import 'f0908_elementary_ca_rule_72_variants.dart';
import 'f0908_elementary_ca_rule_72_metadata.dart';

/// Elementary CA Rule 72 — Cellular & Stochastic.
class F0908ElementaryCaRule72 extends CellularModule {
  F0908ElementaryCaRule72()
      : super(
          id: 'f0908_elementary_ca_rule_72',
          shader: 'shaders/f0908_elementary_ca_rule_72_gpu.frag',
        );

  @override
  F0908ElementaryCaRule72Metadata get metadata => F0908ElementaryCaRule72Metadata.instance;

  @override
  List<F0908ElementaryCaRule72Preset> get presets => F0908ElementaryCaRule72Presets.all;

  @override
  List<F0908ElementaryCaRule72Variant> get variants => F0908ElementaryCaRule72Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
