// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0932_elementary_ca_rule_136_presets.dart';
import 'f0932_elementary_ca_rule_136_variants.dart';
import 'f0932_elementary_ca_rule_136_metadata.dart';

/// Elementary CA Rule 136 — Cellular & Stochastic.
class F0932ElementaryCaRule136 extends CellularModule {
  F0932ElementaryCaRule136()
      : super(
          id: 'f0932_elementary_ca_rule_136',
          shader: 'shaders/f0932_elementary_ca_rule_136_gpu.frag',
        );

  @override
  F0932ElementaryCaRule136Metadata get metadata => F0932ElementaryCaRule136Metadata.instance;

  @override
  List<F0932ElementaryCaRule136Preset> get presets => F0932ElementaryCaRule136Presets.all;

  @override
  List<F0932ElementaryCaRule136Variant> get variants => F0932ElementaryCaRule136Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
