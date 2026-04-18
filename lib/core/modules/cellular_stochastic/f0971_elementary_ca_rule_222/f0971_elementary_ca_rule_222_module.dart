// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0971_elementary_ca_rule_222_presets.dart';
import 'f0971_elementary_ca_rule_222_variants.dart';
import 'f0971_elementary_ca_rule_222_metadata.dart';

/// Elementary CA Rule 222 — Cellular & Stochastic.
class F0971ElementaryCaRule222 extends CellularModule {
  F0971ElementaryCaRule222()
      : super(
          id: 'f0971_elementary_ca_rule_222',
          shader: 'shaders/f0971_elementary_ca_rule_222_gpu.frag',
        );

  @override
  F0971ElementaryCaRule222Metadata get metadata => F0971ElementaryCaRule222Metadata.instance;

  @override
  List<F0971ElementaryCaRule222Preset> get presets => F0971ElementaryCaRule222Presets.all;

  @override
  List<F0971ElementaryCaRule222Variant> get variants => F0971ElementaryCaRule222Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
