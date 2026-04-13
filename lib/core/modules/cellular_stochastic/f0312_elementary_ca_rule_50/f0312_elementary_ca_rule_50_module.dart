// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0312_elementary_ca_rule_50_presets.dart';
import 'f0312_elementary_ca_rule_50_variants.dart';
import 'f0312_elementary_ca_rule_50_metadata.dart';

/// Elementary CA Rule 50 — Cellular & Stochastic.
class F0312ElementaryCaRule50 extends CellularModule {
  F0312ElementaryCaRule50()
      : super(
          id: 'f0312_elementary_ca_rule_50',
          shader: 'shaders/f0312_elementary_ca_rule_50_gpu.frag',
        );

  @override
  F0312ElementaryCaRule50Metadata get metadata => F0312ElementaryCaRule50Metadata.instance;

  @override
  List<F0312ElementaryCaRule50Preset> get presets => F0312ElementaryCaRule50Presets.all;

  @override
  List<F0312ElementaryCaRule50Variant> get variants => F0312ElementaryCaRule50Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
