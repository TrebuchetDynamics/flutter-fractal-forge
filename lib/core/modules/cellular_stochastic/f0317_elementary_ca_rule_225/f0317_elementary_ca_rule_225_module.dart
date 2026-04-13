// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0317_elementary_ca_rule_225_presets.dart';
import 'f0317_elementary_ca_rule_225_variants.dart';
import 'f0317_elementary_ca_rule_225_metadata.dart';

/// Elementary CA Rule 225 — Cellular & Stochastic.
class F0317ElementaryCaRule225 extends CellularModule {
  F0317ElementaryCaRule225()
      : super(
          id: 'f0317_elementary_ca_rule_225',
          shader: 'shaders/f0317_elementary_ca_rule_225_gpu.frag',
        );

  @override
  F0317ElementaryCaRule225Metadata get metadata => F0317ElementaryCaRule225Metadata.instance;

  @override
  List<F0317ElementaryCaRule225Preset> get presets => F0317ElementaryCaRule225Presets.all;

  @override
  List<F0317ElementaryCaRule225Variant> get variants => F0317ElementaryCaRule225Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
