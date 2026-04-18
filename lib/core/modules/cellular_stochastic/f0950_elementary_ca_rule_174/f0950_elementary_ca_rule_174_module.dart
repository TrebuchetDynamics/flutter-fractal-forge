// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0950_elementary_ca_rule_174_presets.dart';
import 'f0950_elementary_ca_rule_174_variants.dart';
import 'f0950_elementary_ca_rule_174_metadata.dart';

/// Elementary CA Rule 174 — Cellular & Stochastic.
class F0950ElementaryCaRule174 extends CellularModule {
  F0950ElementaryCaRule174()
      : super(
          id: 'f0950_elementary_ca_rule_174',
          shader: 'shaders/f0950_elementary_ca_rule_174_gpu.frag',
        );

  @override
  F0950ElementaryCaRule174Metadata get metadata => F0950ElementaryCaRule174Metadata.instance;

  @override
  List<F0950ElementaryCaRule174Preset> get presets => F0950ElementaryCaRule174Presets.all;

  @override
  List<F0950ElementaryCaRule174Variant> get variants => F0950ElementaryCaRule174Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
