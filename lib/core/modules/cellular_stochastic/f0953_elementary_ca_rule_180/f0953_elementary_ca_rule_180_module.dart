// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0953_elementary_ca_rule_180_presets.dart';
import 'f0953_elementary_ca_rule_180_variants.dart';
import 'f0953_elementary_ca_rule_180_metadata.dart';

/// Elementary CA Rule 180 — Cellular & Stochastic.
class F0953ElementaryCaRule180 extends CellularModule {
  F0953ElementaryCaRule180()
      : super(
          id: 'f0953_elementary_ca_rule_180',
          shader: 'shaders/f0953_elementary_ca_rule_180_gpu.frag',
        );

  @override
  F0953ElementaryCaRule180Metadata get metadata => F0953ElementaryCaRule180Metadata.instance;

  @override
  List<F0953ElementaryCaRule180Preset> get presets => F0953ElementaryCaRule180Presets.all;

  @override
  List<F0953ElementaryCaRule180Variant> get variants => F0953ElementaryCaRule180Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
