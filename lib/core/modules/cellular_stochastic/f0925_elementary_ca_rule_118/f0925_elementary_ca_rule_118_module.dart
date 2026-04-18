// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0925_elementary_ca_rule_118_presets.dart';
import 'f0925_elementary_ca_rule_118_variants.dart';
import 'f0925_elementary_ca_rule_118_metadata.dart';

/// Elementary CA Rule 118 — Cellular & Stochastic.
class F0925ElementaryCaRule118 extends CellularModule {
  F0925ElementaryCaRule118()
      : super(
          id: 'f0925_elementary_ca_rule_118',
          shader: 'shaders/f0925_elementary_ca_rule_118_gpu.frag',
        );

  @override
  F0925ElementaryCaRule118Metadata get metadata => F0925ElementaryCaRule118Metadata.instance;

  @override
  List<F0925ElementaryCaRule118Preset> get presets => F0925ElementaryCaRule118Presets.all;

  @override
  List<F0925ElementaryCaRule118Variant> get variants => F0925ElementaryCaRule118Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
