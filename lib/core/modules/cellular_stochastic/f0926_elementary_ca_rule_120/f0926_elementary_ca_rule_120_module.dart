// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0926_elementary_ca_rule_120_presets.dart';
import 'f0926_elementary_ca_rule_120_variants.dart';
import 'f0926_elementary_ca_rule_120_metadata.dart';

/// Elementary CA Rule 120 — Cellular & Stochastic.
class F0926ElementaryCaRule120 extends CellularModule {
  F0926ElementaryCaRule120()
      : super(
          id: 'f0926_elementary_ca_rule_120',
          shader: 'shaders/f0926_elementary_ca_rule_120_gpu.frag',
        );

  @override
  F0926ElementaryCaRule120Metadata get metadata => F0926ElementaryCaRule120Metadata.instance;

  @override
  List<F0926ElementaryCaRule120Preset> get presets => F0926ElementaryCaRule120Presets.all;

  @override
  List<F0926ElementaryCaRule120Variant> get variants => F0926ElementaryCaRule120Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
