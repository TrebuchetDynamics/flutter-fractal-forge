// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0890_elementary_ca_rule_20_presets.dart';
import 'f0890_elementary_ca_rule_20_variants.dart';
import 'f0890_elementary_ca_rule_20_metadata.dart';

/// Elementary CA Rule 20 — Cellular & Stochastic.
class F0890ElementaryCaRule20 extends CellularModule {
  F0890ElementaryCaRule20()
      : super(
          id: 'f0890_elementary_ca_rule_20',
          shader: 'shaders/f0890_elementary_ca_rule_20_gpu.frag',
        );

  @override
  F0890ElementaryCaRule20Metadata get metadata => F0890ElementaryCaRule20Metadata.instance;

  @override
  List<F0890ElementaryCaRule20Preset> get presets => F0890ElementaryCaRule20Presets.all;

  @override
  List<F0890ElementaryCaRule20Variant> get variants => F0890ElementaryCaRule20Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
