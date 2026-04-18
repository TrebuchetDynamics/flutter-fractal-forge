// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0882_elementary_ca_rule_4_presets.dart';
import 'f0882_elementary_ca_rule_4_variants.dart';
import 'f0882_elementary_ca_rule_4_metadata.dart';

/// Elementary CA Rule 4 — Cellular & Stochastic.
class F0882ElementaryCaRule4 extends CellularModule {
  F0882ElementaryCaRule4()
      : super(
          id: 'f0882_elementary_ca_rule_4',
          shader: 'shaders/f0882_elementary_ca_rule_4_gpu.frag',
        );

  @override
  F0882ElementaryCaRule4Metadata get metadata => F0882ElementaryCaRule4Metadata.instance;

  @override
  List<F0882ElementaryCaRule4Preset> get presets => F0882ElementaryCaRule4Presets.all;

  @override
  List<F0882ElementaryCaRule4Variant> get variants => F0882ElementaryCaRule4Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
