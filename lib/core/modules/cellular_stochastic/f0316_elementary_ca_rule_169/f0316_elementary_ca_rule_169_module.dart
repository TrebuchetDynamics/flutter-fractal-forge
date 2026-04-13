// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0316_elementary_ca_rule_169_presets.dart';
import 'f0316_elementary_ca_rule_169_variants.dart';
import 'f0316_elementary_ca_rule_169_metadata.dart';

/// Elementary CA Rule 169 — Cellular & Stochastic.
class F0316ElementaryCaRule169 extends CellularModule {
  F0316ElementaryCaRule169()
      : super(
          id: 'f0316_elementary_ca_rule_169',
          shader: 'shaders/f0316_elementary_ca_rule_169_gpu.frag',
        );

  @override
  F0316ElementaryCaRule169Metadata get metadata => F0316ElementaryCaRule169Metadata.instance;

  @override
  List<F0316ElementaryCaRule169Preset> get presets => F0316ElementaryCaRule169Presets.all;

  @override
  List<F0316ElementaryCaRule169Variant> get variants => F0316ElementaryCaRule169Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
