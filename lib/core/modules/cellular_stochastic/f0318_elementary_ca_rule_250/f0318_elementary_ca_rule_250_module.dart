// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0318_elementary_ca_rule_250_presets.dart';
import 'f0318_elementary_ca_rule_250_variants.dart';
import 'f0318_elementary_ca_rule_250_metadata.dart';

/// Elementary CA Rule 250 — Cellular & Stochastic.
class F0318ElementaryCaRule250 extends CellularModule {
  F0318ElementaryCaRule250()
      : super(
          id: 'f0318_elementary_ca_rule_250',
          shader: 'shaders/f0318_elementary_ca_rule_250_gpu.frag',
        );

  @override
  F0318ElementaryCaRule250Metadata get metadata => F0318ElementaryCaRule250Metadata.instance;

  @override
  List<F0318ElementaryCaRule250Preset> get presets => F0318ElementaryCaRule250Presets.all;

  @override
  List<F0318ElementaryCaRule250Variant> get variants => F0318ElementaryCaRule250Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
