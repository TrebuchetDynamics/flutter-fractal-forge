// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0968_elementary_ca_rule_214_presets.dart';
import 'f0968_elementary_ca_rule_214_variants.dart';
import 'f0968_elementary_ca_rule_214_metadata.dart';

/// Elementary CA Rule 214 — Cellular & Stochastic.
class F0968ElementaryCaRule214 extends CellularModule {
  F0968ElementaryCaRule214()
      : super(
          id: 'f0968_elementary_ca_rule_214',
          shader: 'shaders/f0968_elementary_ca_rule_214_gpu.frag',
        );

  @override
  F0968ElementaryCaRule214Metadata get metadata => F0968ElementaryCaRule214Metadata.instance;

  @override
  List<F0968ElementaryCaRule214Preset> get presets => F0968ElementaryCaRule214Presets.all;

  @override
  List<F0968ElementaryCaRule214Variant> get variants => F0968ElementaryCaRule214Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
