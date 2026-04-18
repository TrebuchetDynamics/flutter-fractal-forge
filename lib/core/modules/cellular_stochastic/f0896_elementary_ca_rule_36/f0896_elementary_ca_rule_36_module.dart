// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0896_elementary_ca_rule_36_presets.dart';
import 'f0896_elementary_ca_rule_36_variants.dart';
import 'f0896_elementary_ca_rule_36_metadata.dart';

/// Elementary CA Rule 36 — Cellular & Stochastic.
class F0896ElementaryCaRule36 extends CellularModule {
  F0896ElementaryCaRule36()
      : super(
          id: 'f0896_elementary_ca_rule_36',
          shader: 'shaders/f0896_elementary_ca_rule_36_gpu.frag',
        );

  @override
  F0896ElementaryCaRule36Metadata get metadata => F0896ElementaryCaRule36Metadata.instance;

  @override
  List<F0896ElementaryCaRule36Preset> get presets => F0896ElementaryCaRule36Presets.all;

  @override
  List<F0896ElementaryCaRule36Variant> get variants => F0896ElementaryCaRule36Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
