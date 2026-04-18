// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0957_elementary_ca_rule_192_presets.dart';
import 'f0957_elementary_ca_rule_192_variants.dart';
import 'f0957_elementary_ca_rule_192_metadata.dart';

/// Elementary CA Rule 192 — Cellular & Stochastic.
class F0957ElementaryCaRule192 extends CellularModule {
  F0957ElementaryCaRule192()
      : super(
          id: 'f0957_elementary_ca_rule_192',
          shader: 'shaders/f0957_elementary_ca_rule_192_gpu.frag',
        );

  @override
  F0957ElementaryCaRule192Metadata get metadata => F0957ElementaryCaRule192Metadata.instance;

  @override
  List<F0957ElementaryCaRule192Preset> get presets => F0957ElementaryCaRule192Presets.all;

  @override
  List<F0957ElementaryCaRule192Variant> get variants => F0957ElementaryCaRule192Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
