// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0944_elementary_ca_rule_162_presets.dart';
import 'f0944_elementary_ca_rule_162_variants.dart';
import 'f0944_elementary_ca_rule_162_metadata.dart';

/// Elementary CA Rule 162 — Cellular & Stochastic.
class F0944ElementaryCaRule162 extends CellularModule {
  F0944ElementaryCaRule162()
      : super(
          id: 'f0944_elementary_ca_rule_162',
          shader: 'shaders/f0944_elementary_ca_rule_162_gpu.frag',
        );

  @override
  F0944ElementaryCaRule162Metadata get metadata => F0944ElementaryCaRule162Metadata.instance;

  @override
  List<F0944ElementaryCaRule162Preset> get presets => F0944ElementaryCaRule162Presets.all;

  @override
  List<F0944ElementaryCaRule162Variant> get variants => F0944ElementaryCaRule162Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
