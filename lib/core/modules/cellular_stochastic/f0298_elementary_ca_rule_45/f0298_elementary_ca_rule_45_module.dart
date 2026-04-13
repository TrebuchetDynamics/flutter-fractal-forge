// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0298_elementary_ca_rule_45_presets.dart';
import 'f0298_elementary_ca_rule_45_variants.dart';
import 'f0298_elementary_ca_rule_45_metadata.dart';

/// Elementary CA Rule 45 — Cellular & Stochastic.
class F0298ElementaryCaRule45 extends CellularModule {
  F0298ElementaryCaRule45()
      : super(
          id: 'f0298_elementary_ca_rule_45',
          shader: 'shaders/f0298_elementary_ca_rule_45_gpu.frag',
        );

  @override
  F0298ElementaryCaRule45Metadata get metadata => F0298ElementaryCaRule45Metadata.instance;

  @override
  List<F0298ElementaryCaRule45Preset> get presets => F0298ElementaryCaRule45Presets.all;

  @override
  List<F0298ElementaryCaRule45Variant> get variants => F0298ElementaryCaRule45Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
