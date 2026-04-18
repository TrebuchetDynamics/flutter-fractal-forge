// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0939_elementary_ca_rule_152_presets.dart';
import 'f0939_elementary_ca_rule_152_variants.dart';
import 'f0939_elementary_ca_rule_152_metadata.dart';

/// Elementary CA Rule 152 — Cellular & Stochastic.
class F0939ElementaryCaRule152 extends CellularModule {
  F0939ElementaryCaRule152()
      : super(
          id: 'f0939_elementary_ca_rule_152',
          shader: 'shaders/f0939_elementary_ca_rule_152_gpu.frag',
        );

  @override
  F0939ElementaryCaRule152Metadata get metadata => F0939ElementaryCaRule152Metadata.instance;

  @override
  List<F0939ElementaryCaRule152Preset> get presets => F0939ElementaryCaRule152Presets.all;

  @override
  List<F0939ElementaryCaRule152Variant> get variants => F0939ElementaryCaRule152Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
