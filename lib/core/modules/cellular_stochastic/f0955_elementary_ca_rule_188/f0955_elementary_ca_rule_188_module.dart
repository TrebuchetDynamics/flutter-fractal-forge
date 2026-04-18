// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0955_elementary_ca_rule_188_presets.dart';
import 'f0955_elementary_ca_rule_188_variants.dart';
import 'f0955_elementary_ca_rule_188_metadata.dart';

/// Elementary CA Rule 188 — Cellular & Stochastic.
class F0955ElementaryCaRule188 extends CellularModule {
  F0955ElementaryCaRule188()
      : super(
          id: 'f0955_elementary_ca_rule_188',
          shader: 'shaders/f0955_elementary_ca_rule_188_gpu.frag',
        );

  @override
  F0955ElementaryCaRule188Metadata get metadata => F0955ElementaryCaRule188Metadata.instance;

  @override
  List<F0955ElementaryCaRule188Preset> get presets => F0955ElementaryCaRule188Presets.all;

  @override
  List<F0955ElementaryCaRule188Variant> get variants => F0955ElementaryCaRule188Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
