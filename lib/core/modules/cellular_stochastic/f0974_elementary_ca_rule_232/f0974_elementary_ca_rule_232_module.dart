// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0974_elementary_ca_rule_232_presets.dart';
import 'f0974_elementary_ca_rule_232_variants.dart';
import 'f0974_elementary_ca_rule_232_metadata.dart';

/// Elementary CA Rule 232 — Cellular & Stochastic.
class F0974ElementaryCaRule232 extends CellularModule {
  F0974ElementaryCaRule232()
      : super(
          id: 'f0974_elementary_ca_rule_232',
          shader: 'shaders/f0974_elementary_ca_rule_232_gpu.frag',
        );

  @override
  F0974ElementaryCaRule232Metadata get metadata => F0974ElementaryCaRule232Metadata.instance;

  @override
  List<F0974ElementaryCaRule232Preset> get presets => F0974ElementaryCaRule232Presets.all;

  @override
  List<F0974ElementaryCaRule232Variant> get variants => F0974ElementaryCaRule232Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
