// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0901_elementary_ca_rule_46_presets.dart';
import 'f0901_elementary_ca_rule_46_variants.dart';
import 'f0901_elementary_ca_rule_46_metadata.dart';

/// Elementary CA Rule 46 — Cellular & Stochastic.
class F0901ElementaryCaRule46 extends CellularModule {
  F0901ElementaryCaRule46()
      : super(
          id: 'f0901_elementary_ca_rule_46',
          shader: 'shaders/f0901_elementary_ca_rule_46_gpu.frag',
        );

  @override
  F0901ElementaryCaRule46Metadata get metadata => F0901ElementaryCaRule46Metadata.instance;

  @override
  List<F0901ElementaryCaRule46Preset> get presets => F0901ElementaryCaRule46Presets.all;

  @override
  List<F0901ElementaryCaRule46Variant> get variants => F0901ElementaryCaRule46Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
