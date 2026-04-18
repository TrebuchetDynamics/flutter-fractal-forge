// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0973_elementary_ca_rule_230_presets.dart';
import 'f0973_elementary_ca_rule_230_variants.dart';
import 'f0973_elementary_ca_rule_230_metadata.dart';

/// Elementary CA Rule 230 — Cellular & Stochastic.
class F0973ElementaryCaRule230 extends CellularModule {
  F0973ElementaryCaRule230()
      : super(
          id: 'f0973_elementary_ca_rule_230',
          shader: 'shaders/f0973_elementary_ca_rule_230_gpu.frag',
        );

  @override
  F0973ElementaryCaRule230Metadata get metadata => F0973ElementaryCaRule230Metadata.instance;

  @override
  List<F0973ElementaryCaRule230Preset> get presets => F0973ElementaryCaRule230Presets.all;

  @override
  List<F0973ElementaryCaRule230Variant> get variants => F0973ElementaryCaRule230Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
