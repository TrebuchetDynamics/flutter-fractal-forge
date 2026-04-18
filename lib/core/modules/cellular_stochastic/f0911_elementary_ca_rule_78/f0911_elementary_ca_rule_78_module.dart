// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0911_elementary_ca_rule_78_presets.dart';
import 'f0911_elementary_ca_rule_78_variants.dart';
import 'f0911_elementary_ca_rule_78_metadata.dart';

/// Elementary CA Rule 78 — Cellular & Stochastic.
class F0911ElementaryCaRule78 extends CellularModule {
  F0911ElementaryCaRule78()
      : super(
          id: 'f0911_elementary_ca_rule_78',
          shader: 'shaders/f0911_elementary_ca_rule_78_gpu.frag',
        );

  @override
  F0911ElementaryCaRule78Metadata get metadata => F0911ElementaryCaRule78Metadata.instance;

  @override
  List<F0911ElementaryCaRule78Preset> get presets => F0911ElementaryCaRule78Presets.all;

  @override
  List<F0911ElementaryCaRule78Variant> get variants => F0911ElementaryCaRule78Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
