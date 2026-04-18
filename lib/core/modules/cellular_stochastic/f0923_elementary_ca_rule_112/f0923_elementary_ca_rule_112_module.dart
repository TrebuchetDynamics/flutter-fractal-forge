// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0923_elementary_ca_rule_112_presets.dart';
import 'f0923_elementary_ca_rule_112_variants.dart';
import 'f0923_elementary_ca_rule_112_metadata.dart';

/// Elementary CA Rule 112 — Cellular & Stochastic.
class F0923ElementaryCaRule112 extends CellularModule {
  F0923ElementaryCaRule112()
      : super(
          id: 'f0923_elementary_ca_rule_112',
          shader: 'shaders/f0923_elementary_ca_rule_112_gpu.frag',
        );

  @override
  F0923ElementaryCaRule112Metadata get metadata => F0923ElementaryCaRule112Metadata.instance;

  @override
  List<F0923ElementaryCaRule112Preset> get presets => F0923ElementaryCaRule112Presets.all;

  @override
  List<F0923ElementaryCaRule112Variant> get variants => F0923ElementaryCaRule112Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
