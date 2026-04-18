// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0905_elementary_ca_rule_66_presets.dart';
import 'f0905_elementary_ca_rule_66_variants.dart';
import 'f0905_elementary_ca_rule_66_metadata.dart';

/// Elementary CA Rule 66 — Cellular & Stochastic.
class F0905ElementaryCaRule66 extends CellularModule {
  F0905ElementaryCaRule66()
      : super(
          id: 'f0905_elementary_ca_rule_66',
          shader: 'shaders/f0905_elementary_ca_rule_66_gpu.frag',
        );

  @override
  F0905ElementaryCaRule66Metadata get metadata => F0905ElementaryCaRule66Metadata.instance;

  @override
  List<F0905ElementaryCaRule66Preset> get presets => F0905ElementaryCaRule66Presets.all;

  @override
  List<F0905ElementaryCaRule66Variant> get variants => F0905ElementaryCaRule66Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
