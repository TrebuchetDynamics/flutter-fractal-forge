// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0959_elementary_ca_rule_196_presets.dart';
import 'f0959_elementary_ca_rule_196_variants.dart';
import 'f0959_elementary_ca_rule_196_metadata.dart';

/// Elementary CA Rule 196 — Cellular & Stochastic.
class F0959ElementaryCaRule196 extends CellularModule {
  F0959ElementaryCaRule196()
      : super(
          id: 'f0959_elementary_ca_rule_196',
          shader: 'shaders/f0959_elementary_ca_rule_196_gpu.frag',
        );

  @override
  F0959ElementaryCaRule196Metadata get metadata => F0959ElementaryCaRule196Metadata.instance;

  @override
  List<F0959ElementaryCaRule196Preset> get presets => F0959ElementaryCaRule196Presets.all;

  @override
  List<F0959ElementaryCaRule196Variant> get variants => F0959ElementaryCaRule196Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
