// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0954_elementary_ca_rule_186_presets.dart';
import 'f0954_elementary_ca_rule_186_variants.dart';
import 'f0954_elementary_ca_rule_186_metadata.dart';

/// Elementary CA Rule 186 — Cellular & Stochastic.
class F0954ElementaryCaRule186 extends CellularModule {
  F0954ElementaryCaRule186()
      : super(
          id: 'f0954_elementary_ca_rule_186',
          shader: 'shaders/f0954_elementary_ca_rule_186_gpu.frag',
        );

  @override
  F0954ElementaryCaRule186Metadata get metadata => F0954ElementaryCaRule186Metadata.instance;

  @override
  List<F0954ElementaryCaRule186Preset> get presets => F0954ElementaryCaRule186Presets.all;

  @override
  List<F0954ElementaryCaRule186Variant> get variants => F0954ElementaryCaRule186Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
