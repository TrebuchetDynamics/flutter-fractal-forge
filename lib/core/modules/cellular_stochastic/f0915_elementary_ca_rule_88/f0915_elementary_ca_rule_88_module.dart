// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0915_elementary_ca_rule_88_presets.dart';
import 'f0915_elementary_ca_rule_88_variants.dart';
import 'f0915_elementary_ca_rule_88_metadata.dart';

/// Elementary CA Rule 88 — Cellular & Stochastic.
class F0915ElementaryCaRule88 extends CellularModule {
  F0915ElementaryCaRule88()
      : super(
          id: 'f0915_elementary_ca_rule_88',
          shader: 'shaders/f0915_elementary_ca_rule_88_gpu.frag',
        );

  @override
  F0915ElementaryCaRule88Metadata get metadata => F0915ElementaryCaRule88Metadata.instance;

  @override
  List<F0915ElementaryCaRule88Preset> get presets => F0915ElementaryCaRule88Presets.all;

  @override
  List<F0915ElementaryCaRule88Variant> get variants => F0915ElementaryCaRule88Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
