// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0976_elementary_ca_rule_238_presets.dart';
import 'f0976_elementary_ca_rule_238_variants.dart';
import 'f0976_elementary_ca_rule_238_metadata.dart';

/// Elementary CA Rule 238 — Cellular & Stochastic.
class F0976ElementaryCaRule238 extends CellularModule {
  F0976ElementaryCaRule238()
      : super(
          id: 'f0976_elementary_ca_rule_238',
          shader: 'shaders/f0976_elementary_ca_rule_238_gpu.frag',
        );

  @override
  F0976ElementaryCaRule238Metadata get metadata => F0976ElementaryCaRule238Metadata.instance;

  @override
  List<F0976ElementaryCaRule238Preset> get presets => F0976ElementaryCaRule238Presets.all;

  @override
  List<F0976ElementaryCaRule238Variant> get variants => F0976ElementaryCaRule238Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
