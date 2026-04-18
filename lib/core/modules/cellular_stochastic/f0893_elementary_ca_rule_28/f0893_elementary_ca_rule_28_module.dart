// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0893_elementary_ca_rule_28_presets.dart';
import 'f0893_elementary_ca_rule_28_variants.dart';
import 'f0893_elementary_ca_rule_28_metadata.dart';

/// Elementary CA Rule 28 — Cellular & Stochastic.
class F0893ElementaryCaRule28 extends CellularModule {
  F0893ElementaryCaRule28()
      : super(
          id: 'f0893_elementary_ca_rule_28',
          shader: 'shaders/f0893_elementary_ca_rule_28_gpu.frag',
        );

  @override
  F0893ElementaryCaRule28Metadata get metadata => F0893ElementaryCaRule28Metadata.instance;

  @override
  List<F0893ElementaryCaRule28Preset> get presets => F0893ElementaryCaRule28Presets.all;

  @override
  List<F0893ElementaryCaRule28Variant> get variants => F0893ElementaryCaRule28Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
