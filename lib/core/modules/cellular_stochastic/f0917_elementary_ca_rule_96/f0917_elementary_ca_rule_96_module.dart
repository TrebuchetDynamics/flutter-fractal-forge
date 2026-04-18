// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0917_elementary_ca_rule_96_presets.dart';
import 'f0917_elementary_ca_rule_96_variants.dart';
import 'f0917_elementary_ca_rule_96_metadata.dart';

/// Elementary CA Rule 96 — Cellular & Stochastic.
class F0917ElementaryCaRule96 extends CellularModule {
  F0917ElementaryCaRule96()
      : super(
          id: 'f0917_elementary_ca_rule_96',
          shader: 'shaders/f0917_elementary_ca_rule_96_gpu.frag',
        );

  @override
  F0917ElementaryCaRule96Metadata get metadata => F0917ElementaryCaRule96Metadata.instance;

  @override
  List<F0917ElementaryCaRule96Preset> get presets => F0917ElementaryCaRule96Presets.all;

  @override
  List<F0917ElementaryCaRule96Variant> get variants => F0917ElementaryCaRule96Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
