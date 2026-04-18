// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0935_elementary_ca_rule_142_presets.dart';
import 'f0935_elementary_ca_rule_142_variants.dart';
import 'f0935_elementary_ca_rule_142_metadata.dart';

/// Elementary CA Rule 142 — Cellular & Stochastic.
class F0935ElementaryCaRule142 extends CellularModule {
  F0935ElementaryCaRule142()
      : super(
          id: 'f0935_elementary_ca_rule_142',
          shader: 'shaders/f0935_elementary_ca_rule_142_gpu.frag',
        );

  @override
  F0935ElementaryCaRule142Metadata get metadata => F0935ElementaryCaRule142Metadata.instance;

  @override
  List<F0935ElementaryCaRule142Preset> get presets => F0935ElementaryCaRule142Presets.all;

  @override
  List<F0935ElementaryCaRule142Variant> get variants => F0935ElementaryCaRule142Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
