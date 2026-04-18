// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0884_elementary_ca_rule_8_presets.dart';
import 'f0884_elementary_ca_rule_8_variants.dart';
import 'f0884_elementary_ca_rule_8_metadata.dart';

/// Elementary CA Rule 8 — Cellular & Stochastic.
class F0884ElementaryCaRule8 extends CellularModule {
  F0884ElementaryCaRule8()
      : super(
          id: 'f0884_elementary_ca_rule_8',
          shader: 'shaders/f0884_elementary_ca_rule_8_gpu.frag',
        );

  @override
  F0884ElementaryCaRule8Metadata get metadata => F0884ElementaryCaRule8Metadata.instance;

  @override
  List<F0884ElementaryCaRule8Preset> get presets => F0884ElementaryCaRule8Presets.all;

  @override
  List<F0884ElementaryCaRule8Variant> get variants => F0884ElementaryCaRule8Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
