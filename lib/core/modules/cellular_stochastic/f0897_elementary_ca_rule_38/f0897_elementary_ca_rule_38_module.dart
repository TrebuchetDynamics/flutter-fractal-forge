// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0897_elementary_ca_rule_38_presets.dart';
import 'f0897_elementary_ca_rule_38_variants.dart';
import 'f0897_elementary_ca_rule_38_metadata.dart';

/// Elementary CA Rule 38 — Cellular & Stochastic.
class F0897ElementaryCaRule38 extends CellularModule {
  F0897ElementaryCaRule38()
      : super(
          id: 'f0897_elementary_ca_rule_38',
          shader: 'shaders/f0897_elementary_ca_rule_38_gpu.frag',
        );

  @override
  F0897ElementaryCaRule38Metadata get metadata => F0897ElementaryCaRule38Metadata.instance;

  @override
  List<F0897ElementaryCaRule38Preset> get presets => F0897ElementaryCaRule38Presets.all;

  @override
  List<F0897ElementaryCaRule38Variant> get variants => F0897ElementaryCaRule38Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
