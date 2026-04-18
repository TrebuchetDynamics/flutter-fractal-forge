// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0945_elementary_ca_rule_164_presets.dart';
import 'f0945_elementary_ca_rule_164_variants.dart';
import 'f0945_elementary_ca_rule_164_metadata.dart';

/// Elementary CA Rule 164 — Cellular & Stochastic.
class F0945ElementaryCaRule164 extends CellularModule {
  F0945ElementaryCaRule164()
      : super(
          id: 'f0945_elementary_ca_rule_164',
          shader: 'shaders/f0945_elementary_ca_rule_164_gpu.frag',
        );

  @override
  F0945ElementaryCaRule164Metadata get metadata => F0945ElementaryCaRule164Metadata.instance;

  @override
  List<F0945ElementaryCaRule164Preset> get presets => F0945ElementaryCaRule164Presets.all;

  @override
  List<F0945ElementaryCaRule164Variant> get variants => F0945ElementaryCaRule164Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
