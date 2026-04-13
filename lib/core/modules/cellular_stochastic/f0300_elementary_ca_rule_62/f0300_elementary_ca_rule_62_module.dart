// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0300_elementary_ca_rule_62_presets.dart';
import 'f0300_elementary_ca_rule_62_variants.dart';
import 'f0300_elementary_ca_rule_62_metadata.dart';

/// Elementary CA Rule 62 — Cellular & Stochastic.
class F0300ElementaryCaRule62 extends CellularModule {
  F0300ElementaryCaRule62()
      : super(
          id: 'f0300_elementary_ca_rule_62',
          shader: 'shaders/f0300_elementary_ca_rule_62_gpu.frag',
        );

  @override
  F0300ElementaryCaRule62Metadata get metadata => F0300ElementaryCaRule62Metadata.instance;

  @override
  List<F0300ElementaryCaRule62Preset> get presets => F0300ElementaryCaRule62Presets.all;

  @override
  List<F0300ElementaryCaRule62Variant> get variants => F0300ElementaryCaRule62Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
