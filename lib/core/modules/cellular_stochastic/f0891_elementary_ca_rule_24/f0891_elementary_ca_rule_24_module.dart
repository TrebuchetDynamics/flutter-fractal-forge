// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0891_elementary_ca_rule_24_presets.dart';
import 'f0891_elementary_ca_rule_24_variants.dart';
import 'f0891_elementary_ca_rule_24_metadata.dart';

/// Elementary CA Rule 24 — Cellular & Stochastic.
class F0891ElementaryCaRule24 extends CellularModule {
  F0891ElementaryCaRule24()
      : super(
          id: 'f0891_elementary_ca_rule_24',
          shader: 'shaders/f0891_elementary_ca_rule_24_gpu.frag',
        );

  @override
  F0891ElementaryCaRule24Metadata get metadata => F0891ElementaryCaRule24Metadata.instance;

  @override
  List<F0891ElementaryCaRule24Preset> get presets => F0891ElementaryCaRule24Presets.all;

  @override
  List<F0891ElementaryCaRule24Variant> get variants => F0891ElementaryCaRule24Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
