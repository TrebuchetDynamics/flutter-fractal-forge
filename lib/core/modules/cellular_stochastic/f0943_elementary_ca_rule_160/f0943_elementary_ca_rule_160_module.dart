// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0943_elementary_ca_rule_160_presets.dart';
import 'f0943_elementary_ca_rule_160_variants.dart';
import 'f0943_elementary_ca_rule_160_metadata.dart';

/// Elementary CA Rule 160 — Cellular & Stochastic.
class F0943ElementaryCaRule160 extends CellularModule {
  F0943ElementaryCaRule160()
      : super(
          id: 'f0943_elementary_ca_rule_160',
          shader: 'shaders/f0943_elementary_ca_rule_160_gpu.frag',
        );

  @override
  F0943ElementaryCaRule160Metadata get metadata => F0943ElementaryCaRule160Metadata.instance;

  @override
  List<F0943ElementaryCaRule160Preset> get presets => F0943ElementaryCaRule160Presets.all;

  @override
  List<F0943ElementaryCaRule160Variant> get variants => F0943ElementaryCaRule160Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
