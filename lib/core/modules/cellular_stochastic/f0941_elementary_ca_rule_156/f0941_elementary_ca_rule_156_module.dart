// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0941_elementary_ca_rule_156_presets.dart';
import 'f0941_elementary_ca_rule_156_variants.dart';
import 'f0941_elementary_ca_rule_156_metadata.dart';

/// Elementary CA Rule 156 — Cellular & Stochastic.
class F0941ElementaryCaRule156 extends CellularModule {
  F0941ElementaryCaRule156()
      : super(
          id: 'f0941_elementary_ca_rule_156',
          shader: 'shaders/f0941_elementary_ca_rule_156_gpu.frag',
        );

  @override
  F0941ElementaryCaRule156Metadata get metadata => F0941ElementaryCaRule156Metadata.instance;

  @override
  List<F0941ElementaryCaRule156Preset> get presets => F0941ElementaryCaRule156Presets.all;

  @override
  List<F0941ElementaryCaRule156Variant> get variants => F0941ElementaryCaRule156Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
