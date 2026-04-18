// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0969_elementary_ca_rule_218_presets.dart';
import 'f0969_elementary_ca_rule_218_variants.dart';
import 'f0969_elementary_ca_rule_218_metadata.dart';

/// Elementary CA Rule 218 — Cellular & Stochastic.
class F0969ElementaryCaRule218 extends CellularModule {
  F0969ElementaryCaRule218()
      : super(
          id: 'f0969_elementary_ca_rule_218',
          shader: 'shaders/f0969_elementary_ca_rule_218_gpu.frag',
        );

  @override
  F0969ElementaryCaRule218Metadata get metadata => F0969ElementaryCaRule218Metadata.instance;

  @override
  List<F0969ElementaryCaRule218Preset> get presets => F0969ElementaryCaRule218Presets.all;

  @override
  List<F0969ElementaryCaRule218Variant> get variants => F0969ElementaryCaRule218Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
