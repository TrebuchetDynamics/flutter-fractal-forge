// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0297_elementary_ca_rule_30_presets.dart';
import 'f0297_elementary_ca_rule_30_variants.dart';
import 'f0297_elementary_ca_rule_30_metadata.dart';

/// Elementary CA Rule 30 — Cellular & Stochastic.
class F0297ElementaryCaRule30 extends CellularModule {
  F0297ElementaryCaRule30()
      : super(
          id: 'f0297_elementary_ca_rule_30',
          shader: 'shaders/f0297_elementary_ca_rule_30_gpu.frag',
        );

  @override
  F0297ElementaryCaRule30Metadata get metadata => F0297ElementaryCaRule30Metadata.instance;

  @override
  List<F0297ElementaryCaRule30Preset> get presets => F0297ElementaryCaRule30Presets.all;

  @override
  List<F0297ElementaryCaRule30Variant> get variants => F0297ElementaryCaRule30Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
