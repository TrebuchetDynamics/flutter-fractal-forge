// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0970_elementary_ca_rule_220_presets.dart';
import 'f0970_elementary_ca_rule_220_variants.dart';
import 'f0970_elementary_ca_rule_220_metadata.dart';

/// Elementary CA Rule 220 — Cellular & Stochastic.
class F0970ElementaryCaRule220 extends CellularModule {
  F0970ElementaryCaRule220()
      : super(
          id: 'f0970_elementary_ca_rule_220',
          shader: 'shaders/f0970_elementary_ca_rule_220_gpu.frag',
        );

  @override
  F0970ElementaryCaRule220Metadata get metadata => F0970ElementaryCaRule220Metadata.instance;

  @override
  List<F0970ElementaryCaRule220Preset> get presets => F0970ElementaryCaRule220Presets.all;

  @override
  List<F0970ElementaryCaRule220Variant> get variants => F0970ElementaryCaRule220Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
