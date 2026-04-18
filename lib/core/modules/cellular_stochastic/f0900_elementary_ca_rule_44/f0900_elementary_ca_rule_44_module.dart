// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0900_elementary_ca_rule_44_presets.dart';
import 'f0900_elementary_ca_rule_44_variants.dart';
import 'f0900_elementary_ca_rule_44_metadata.dart';

/// Elementary CA Rule 44 — Cellular & Stochastic.
class F0900ElementaryCaRule44 extends CellularModule {
  F0900ElementaryCaRule44()
      : super(
          id: 'f0900_elementary_ca_rule_44',
          shader: 'shaders/f0900_elementary_ca_rule_44_gpu.frag',
        );

  @override
  F0900ElementaryCaRule44Metadata get metadata => F0900ElementaryCaRule44Metadata.instance;

  @override
  List<F0900ElementaryCaRule44Preset> get presets => F0900ElementaryCaRule44Presets.all;

  @override
  List<F0900ElementaryCaRule44Variant> get variants => F0900ElementaryCaRule44Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
