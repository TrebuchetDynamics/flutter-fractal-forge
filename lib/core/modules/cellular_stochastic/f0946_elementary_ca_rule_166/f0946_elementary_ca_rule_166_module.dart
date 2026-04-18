// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0946_elementary_ca_rule_166_presets.dart';
import 'f0946_elementary_ca_rule_166_variants.dart';
import 'f0946_elementary_ca_rule_166_metadata.dart';

/// Elementary CA Rule 166 — Cellular & Stochastic.
class F0946ElementaryCaRule166 extends CellularModule {
  F0946ElementaryCaRule166()
      : super(
          id: 'f0946_elementary_ca_rule_166',
          shader: 'shaders/f0946_elementary_ca_rule_166_gpu.frag',
        );

  @override
  F0946ElementaryCaRule166Metadata get metadata => F0946ElementaryCaRule166Metadata.instance;

  @override
  List<F0946ElementaryCaRule166Preset> get presets => F0946ElementaryCaRule166Presets.all;

  @override
  List<F0946ElementaryCaRule166Variant> get variants => F0946ElementaryCaRule166Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
