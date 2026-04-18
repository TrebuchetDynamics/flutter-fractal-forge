// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0964_elementary_ca_rule_206_presets.dart';
import 'f0964_elementary_ca_rule_206_variants.dart';
import 'f0964_elementary_ca_rule_206_metadata.dart';

/// Elementary CA Rule 206 — Cellular & Stochastic.
class F0964ElementaryCaRule206 extends CellularModule {
  F0964ElementaryCaRule206()
      : super(
          id: 'f0964_elementary_ca_rule_206',
          shader: 'shaders/f0964_elementary_ca_rule_206_gpu.frag',
        );

  @override
  F0964ElementaryCaRule206Metadata get metadata => F0964ElementaryCaRule206Metadata.instance;

  @override
  List<F0964ElementaryCaRule206Preset> get presets => F0964ElementaryCaRule206Presets.all;

  @override
  List<F0964ElementaryCaRule206Variant> get variants => F0964ElementaryCaRule206Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
