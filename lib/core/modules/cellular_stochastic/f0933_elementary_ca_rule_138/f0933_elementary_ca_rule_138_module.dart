// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0933_elementary_ca_rule_138_presets.dart';
import 'f0933_elementary_ca_rule_138_variants.dart';
import 'f0933_elementary_ca_rule_138_metadata.dart';

/// Elementary CA Rule 138 — Cellular & Stochastic.
class F0933ElementaryCaRule138 extends CellularModule {
  F0933ElementaryCaRule138()
      : super(
          id: 'f0933_elementary_ca_rule_138',
          shader: 'shaders/f0933_elementary_ca_rule_138_gpu.frag',
        );

  @override
  F0933ElementaryCaRule138Metadata get metadata => F0933ElementaryCaRule138Metadata.instance;

  @override
  List<F0933ElementaryCaRule138Preset> get presets => F0933ElementaryCaRule138Presets.all;

  @override
  List<F0933ElementaryCaRule138Variant> get variants => F0933ElementaryCaRule138Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
