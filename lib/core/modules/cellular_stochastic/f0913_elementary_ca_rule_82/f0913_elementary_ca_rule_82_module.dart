// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0913_elementary_ca_rule_82_presets.dart';
import 'f0913_elementary_ca_rule_82_variants.dart';
import 'f0913_elementary_ca_rule_82_metadata.dart';

/// Elementary CA Rule 82 — Cellular & Stochastic.
class F0913ElementaryCaRule82 extends CellularModule {
  F0913ElementaryCaRule82()
      : super(
          id: 'f0913_elementary_ca_rule_82',
          shader: 'shaders/f0913_elementary_ca_rule_82_gpu.frag',
        );

  @override
  F0913ElementaryCaRule82Metadata get metadata => F0913ElementaryCaRule82Metadata.instance;

  @override
  List<F0913ElementaryCaRule82Preset> get presets => F0913ElementaryCaRule82Presets.all;

  @override
  List<F0913ElementaryCaRule82Variant> get variants => F0913ElementaryCaRule82Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
