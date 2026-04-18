// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0892_elementary_ca_rule_26_presets.dart';
import 'f0892_elementary_ca_rule_26_variants.dart';
import 'f0892_elementary_ca_rule_26_metadata.dart';

/// Elementary CA Rule 26 — Cellular & Stochastic.
class F0892ElementaryCaRule26 extends CellularModule {
  F0892ElementaryCaRule26()
      : super(
          id: 'f0892_elementary_ca_rule_26',
          shader: 'shaders/f0892_elementary_ca_rule_26_gpu.frag',
        );

  @override
  F0892ElementaryCaRule26Metadata get metadata => F0892ElementaryCaRule26Metadata.instance;

  @override
  List<F0892ElementaryCaRule26Preset> get presets => F0892ElementaryCaRule26Presets.all;

  @override
  List<F0892ElementaryCaRule26Variant> get variants => F0892ElementaryCaRule26Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
