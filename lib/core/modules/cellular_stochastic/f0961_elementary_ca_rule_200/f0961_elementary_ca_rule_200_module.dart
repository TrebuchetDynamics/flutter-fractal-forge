// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0961_elementary_ca_rule_200_presets.dart';
import 'f0961_elementary_ca_rule_200_variants.dart';
import 'f0961_elementary_ca_rule_200_metadata.dart';

/// Elementary CA Rule 200 — Cellular & Stochastic.
class F0961ElementaryCaRule200 extends CellularModule {
  F0961ElementaryCaRule200()
      : super(
          id: 'f0961_elementary_ca_rule_200',
          shader: 'shaders/f0961_elementary_ca_rule_200_gpu.frag',
        );

  @override
  F0961ElementaryCaRule200Metadata get metadata => F0961ElementaryCaRule200Metadata.instance;

  @override
  List<F0961ElementaryCaRule200Preset> get presets => F0961ElementaryCaRule200Presets.all;

  @override
  List<F0961ElementaryCaRule200Variant> get variants => F0961ElementaryCaRule200Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
