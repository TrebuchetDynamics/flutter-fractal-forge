// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0920_elementary_ca_rule_104_presets.dart';
import 'f0920_elementary_ca_rule_104_variants.dart';
import 'f0920_elementary_ca_rule_104_metadata.dart';

/// Elementary CA Rule 104 — Cellular & Stochastic.
class F0920ElementaryCaRule104 extends CellularModule {
  F0920ElementaryCaRule104()
      : super(
          id: 'f0920_elementary_ca_rule_104',
          shader: 'shaders/f0920_elementary_ca_rule_104_gpu.frag',
        );

  @override
  F0920ElementaryCaRule104Metadata get metadata => F0920ElementaryCaRule104Metadata.instance;

  @override
  List<F0920ElementaryCaRule104Preset> get presets => F0920ElementaryCaRule104Presets.all;

  @override
  List<F0920ElementaryCaRule104Variant> get variants => F0920ElementaryCaRule104Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
