// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0931_elementary_ca_rule_134_presets.dart';
import 'f0931_elementary_ca_rule_134_variants.dart';
import 'f0931_elementary_ca_rule_134_metadata.dart';

/// Elementary CA Rule 134 — Cellular & Stochastic.
class F0931ElementaryCaRule134 extends CellularModule {
  F0931ElementaryCaRule134()
      : super(
          id: 'f0931_elementary_ca_rule_134',
          shader: 'shaders/f0931_elementary_ca_rule_134_gpu.frag',
        );

  @override
  F0931ElementaryCaRule134Metadata get metadata => F0931ElementaryCaRule134Metadata.instance;

  @override
  List<F0931ElementaryCaRule134Preset> get presets => F0931ElementaryCaRule134Presets.all;

  @override
  List<F0931ElementaryCaRule134Variant> get variants => F0931ElementaryCaRule134Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
