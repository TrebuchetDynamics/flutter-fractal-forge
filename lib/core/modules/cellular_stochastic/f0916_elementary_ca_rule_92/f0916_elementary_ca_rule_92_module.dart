// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0916_elementary_ca_rule_92_presets.dart';
import 'f0916_elementary_ca_rule_92_variants.dart';
import 'f0916_elementary_ca_rule_92_metadata.dart';

/// Elementary CA Rule 92 — Cellular & Stochastic.
class F0916ElementaryCaRule92 extends CellularModule {
  F0916ElementaryCaRule92()
      : super(
          id: 'f0916_elementary_ca_rule_92',
          shader: 'shaders/f0916_elementary_ca_rule_92_gpu.frag',
        );

  @override
  F0916ElementaryCaRule92Metadata get metadata => F0916ElementaryCaRule92Metadata.instance;

  @override
  List<F0916ElementaryCaRule92Preset> get presets => F0916ElementaryCaRule92Presets.all;

  @override
  List<F0916ElementaryCaRule92Variant> get variants => F0916ElementaryCaRule92Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
