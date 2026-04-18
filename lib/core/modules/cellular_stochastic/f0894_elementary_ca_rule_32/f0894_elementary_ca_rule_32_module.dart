// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0894_elementary_ca_rule_32_presets.dart';
import 'f0894_elementary_ca_rule_32_variants.dart';
import 'f0894_elementary_ca_rule_32_metadata.dart';

/// Elementary CA Rule 32 — Cellular & Stochastic.
class F0894ElementaryCaRule32 extends CellularModule {
  F0894ElementaryCaRule32()
      : super(
          id: 'f0894_elementary_ca_rule_32',
          shader: 'shaders/f0894_elementary_ca_rule_32_gpu.frag',
        );

  @override
  F0894ElementaryCaRule32Metadata get metadata => F0894ElementaryCaRule32Metadata.instance;

  @override
  List<F0894ElementaryCaRule32Preset> get presets => F0894ElementaryCaRule32Presets.all;

  @override
  List<F0894ElementaryCaRule32Variant> get variants => F0894ElementaryCaRule32Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
