// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0936_elementary_ca_rule_144_presets.dart';
import 'f0936_elementary_ca_rule_144_variants.dart';
import 'f0936_elementary_ca_rule_144_metadata.dart';

/// Elementary CA Rule 144 — Cellular & Stochastic.
class F0936ElementaryCaRule144 extends CellularModule {
  F0936ElementaryCaRule144()
      : super(
          id: 'f0936_elementary_ca_rule_144',
          shader: 'shaders/f0936_elementary_ca_rule_144_gpu.frag',
        );

  @override
  F0936ElementaryCaRule144Metadata get metadata => F0936ElementaryCaRule144Metadata.instance;

  @override
  List<F0936ElementaryCaRule144Preset> get presets => F0936ElementaryCaRule144Presets.all;

  @override
  List<F0936ElementaryCaRule144Variant> get variants => F0936ElementaryCaRule144Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
