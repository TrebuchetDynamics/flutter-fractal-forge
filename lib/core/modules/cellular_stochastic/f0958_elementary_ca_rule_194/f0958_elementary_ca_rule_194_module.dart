// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0958_elementary_ca_rule_194_presets.dart';
import 'f0958_elementary_ca_rule_194_variants.dart';
import 'f0958_elementary_ca_rule_194_metadata.dart';

/// Elementary CA Rule 194 — Cellular & Stochastic.
class F0958ElementaryCaRule194 extends CellularModule {
  F0958ElementaryCaRule194()
      : super(
          id: 'f0958_elementary_ca_rule_194',
          shader: 'shaders/f0958_elementary_ca_rule_194_gpu.frag',
        );

  @override
  F0958ElementaryCaRule194Metadata get metadata => F0958ElementaryCaRule194Metadata.instance;

  @override
  List<F0958ElementaryCaRule194Preset> get presets => F0958ElementaryCaRule194Presets.all;

  @override
  List<F0958ElementaryCaRule194Variant> get variants => F0958ElementaryCaRule194Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
