// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0929_elementary_ca_rule_130_presets.dart';
import 'f0929_elementary_ca_rule_130_variants.dart';
import 'f0929_elementary_ca_rule_130_metadata.dart';

/// Elementary CA Rule 130 — Cellular & Stochastic.
class F0929ElementaryCaRule130 extends CellularModule {
  F0929ElementaryCaRule130()
      : super(
          id: 'f0929_elementary_ca_rule_130',
          shader: 'shaders/f0929_elementary_ca_rule_130_gpu.frag',
        );

  @override
  F0929ElementaryCaRule130Metadata get metadata => F0929ElementaryCaRule130Metadata.instance;

  @override
  List<F0929ElementaryCaRule130Preset> get presets => F0929ElementaryCaRule130Presets.all;

  @override
  List<F0929ElementaryCaRule130Variant> get variants => F0929ElementaryCaRule130Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
