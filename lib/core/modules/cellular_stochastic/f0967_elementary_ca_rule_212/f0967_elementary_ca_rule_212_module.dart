// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0967_elementary_ca_rule_212_presets.dart';
import 'f0967_elementary_ca_rule_212_variants.dart';
import 'f0967_elementary_ca_rule_212_metadata.dart';

/// Elementary CA Rule 212 — Cellular & Stochastic.
class F0967ElementaryCaRule212 extends CellularModule {
  F0967ElementaryCaRule212()
      : super(
          id: 'f0967_elementary_ca_rule_212',
          shader: 'shaders/f0967_elementary_ca_rule_212_gpu.frag',
        );

  @override
  F0967ElementaryCaRule212Metadata get metadata => F0967ElementaryCaRule212Metadata.instance;

  @override
  List<F0967ElementaryCaRule212Preset> get presets => F0967ElementaryCaRule212Presets.all;

  @override
  List<F0967ElementaryCaRule212Variant> get variants => F0967ElementaryCaRule212Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
