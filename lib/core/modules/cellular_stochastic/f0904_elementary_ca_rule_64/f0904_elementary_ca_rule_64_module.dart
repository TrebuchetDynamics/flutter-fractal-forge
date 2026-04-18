// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0904_elementary_ca_rule_64_presets.dart';
import 'f0904_elementary_ca_rule_64_variants.dart';
import 'f0904_elementary_ca_rule_64_metadata.dart';

/// Elementary CA Rule 64 — Cellular & Stochastic.
class F0904ElementaryCaRule64 extends CellularModule {
  F0904ElementaryCaRule64()
      : super(
          id: 'f0904_elementary_ca_rule_64',
          shader: 'shaders/f0904_elementary_ca_rule_64_gpu.frag',
        );

  @override
  F0904ElementaryCaRule64Metadata get metadata => F0904ElementaryCaRule64Metadata.instance;

  @override
  List<F0904ElementaryCaRule64Preset> get presets => F0904ElementaryCaRule64Presets.all;

  @override
  List<F0904ElementaryCaRule64Variant> get variants => F0904ElementaryCaRule64Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
