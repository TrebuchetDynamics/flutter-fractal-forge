// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0301_elementary_ca_rule_73_presets.dart';
import 'f0301_elementary_ca_rule_73_variants.dart';
import 'f0301_elementary_ca_rule_73_metadata.dart';

/// Elementary CA Rule 73 — Cellular & Stochastic.
class F0301ElementaryCaRule73 extends CellularModule {
  F0301ElementaryCaRule73()
      : super(
          id: 'f0301_elementary_ca_rule_73',
          shader: 'shaders/f0301_elementary_ca_rule_73_gpu.frag',
        );

  @override
  F0301ElementaryCaRule73Metadata get metadata => F0301ElementaryCaRule73Metadata.instance;

  @override
  List<F0301ElementaryCaRule73Preset> get presets => F0301ElementaryCaRule73Presets.all;

  @override
  List<F0301ElementaryCaRule73Variant> get variants => F0301ElementaryCaRule73Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
