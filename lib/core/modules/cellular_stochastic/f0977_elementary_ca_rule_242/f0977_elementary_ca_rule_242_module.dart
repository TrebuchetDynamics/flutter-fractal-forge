// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0977_elementary_ca_rule_242_presets.dart';
import 'f0977_elementary_ca_rule_242_variants.dart';
import 'f0977_elementary_ca_rule_242_metadata.dart';

/// Elementary CA Rule 242 — Cellular & Stochastic.
class F0977ElementaryCaRule242 extends CellularModule {
  F0977ElementaryCaRule242()
      : super(
          id: 'f0977_elementary_ca_rule_242',
          shader: 'shaders/f0977_elementary_ca_rule_242_gpu.frag',
        );

  @override
  F0977ElementaryCaRule242Metadata get metadata => F0977ElementaryCaRule242Metadata.instance;

  @override
  List<F0977ElementaryCaRule242Preset> get presets => F0977ElementaryCaRule242Presets.all;

  @override
  List<F0977ElementaryCaRule242Variant> get variants => F0977ElementaryCaRule242Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
