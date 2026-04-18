// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0965_elementary_ca_rule_208_presets.dart';
import 'f0965_elementary_ca_rule_208_variants.dart';
import 'f0965_elementary_ca_rule_208_metadata.dart';

/// Elementary CA Rule 208 — Cellular & Stochastic.
class F0965ElementaryCaRule208 extends CellularModule {
  F0965ElementaryCaRule208()
      : super(
          id: 'f0965_elementary_ca_rule_208',
          shader: 'shaders/f0965_elementary_ca_rule_208_gpu.frag',
        );

  @override
  F0965ElementaryCaRule208Metadata get metadata => F0965ElementaryCaRule208Metadata.instance;

  @override
  List<F0965ElementaryCaRule208Preset> get presets => F0965ElementaryCaRule208Presets.all;

  @override
  List<F0965ElementaryCaRule208Variant> get variants => F0965ElementaryCaRule208Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
