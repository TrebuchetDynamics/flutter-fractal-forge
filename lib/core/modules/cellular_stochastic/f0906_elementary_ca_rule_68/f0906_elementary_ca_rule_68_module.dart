// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0906_elementary_ca_rule_68_presets.dart';
import 'f0906_elementary_ca_rule_68_variants.dart';
import 'f0906_elementary_ca_rule_68_metadata.dart';

/// Elementary CA Rule 68 — Cellular & Stochastic.
class F0906ElementaryCaRule68 extends CellularModule {
  F0906ElementaryCaRule68()
      : super(
          id: 'f0906_elementary_ca_rule_68',
          shader: 'shaders/f0906_elementary_ca_rule_68_gpu.frag',
        );

  @override
  F0906ElementaryCaRule68Metadata get metadata => F0906ElementaryCaRule68Metadata.instance;

  @override
  List<F0906ElementaryCaRule68Preset> get presets => F0906ElementaryCaRule68Presets.all;

  @override
  List<F0906ElementaryCaRule68Variant> get variants => F0906ElementaryCaRule68Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
