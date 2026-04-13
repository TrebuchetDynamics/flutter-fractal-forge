// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0313_elementary_ca_rule_60_presets.dart';
import 'f0313_elementary_ca_rule_60_variants.dart';
import 'f0313_elementary_ca_rule_60_metadata.dart';

/// Elementary CA Rule 60 — Cellular & Stochastic.
class F0313ElementaryCaRule60 extends CellularModule {
  F0313ElementaryCaRule60()
      : super(
          id: 'f0313_elementary_ca_rule_60',
          shader: 'shaders/f0313_elementary_ca_rule_60_gpu.frag',
        );

  @override
  F0313ElementaryCaRule60Metadata get metadata => F0313ElementaryCaRule60Metadata.instance;

  @override
  List<F0313ElementaryCaRule60Preset> get presets => F0313ElementaryCaRule60Presets.all;

  @override
  List<F0313ElementaryCaRule60Variant> get variants => F0313ElementaryCaRule60Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
