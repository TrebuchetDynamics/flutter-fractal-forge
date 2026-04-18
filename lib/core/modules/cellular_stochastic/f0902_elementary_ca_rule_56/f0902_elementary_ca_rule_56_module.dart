// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0902_elementary_ca_rule_56_presets.dart';
import 'f0902_elementary_ca_rule_56_variants.dart';
import 'f0902_elementary_ca_rule_56_metadata.dart';

/// Elementary CA Rule 56 — Cellular & Stochastic.
class F0902ElementaryCaRule56 extends CellularModule {
  F0902ElementaryCaRule56()
      : super(
          id: 'f0902_elementary_ca_rule_56',
          shader: 'shaders/f0902_elementary_ca_rule_56_gpu.frag',
        );

  @override
  F0902ElementaryCaRule56Metadata get metadata => F0902ElementaryCaRule56Metadata.instance;

  @override
  List<F0902ElementaryCaRule56Preset> get presets => F0902ElementaryCaRule56Presets.all;

  @override
  List<F0902ElementaryCaRule56Variant> get variants => F0902ElementaryCaRule56Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
