// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0956_elementary_ca_rule_190_presets.dart';
import 'f0956_elementary_ca_rule_190_variants.dart';
import 'f0956_elementary_ca_rule_190_metadata.dart';

/// Elementary CA Rule 190 — Cellular & Stochastic.
class F0956ElementaryCaRule190 extends CellularModule {
  F0956ElementaryCaRule190()
      : super(
          id: 'f0956_elementary_ca_rule_190',
          shader: 'shaders/f0956_elementary_ca_rule_190_gpu.frag',
        );

  @override
  F0956ElementaryCaRule190Metadata get metadata => F0956ElementaryCaRule190Metadata.instance;

  @override
  List<F0956ElementaryCaRule190Preset> get presets => F0956ElementaryCaRule190Presets.all;

  @override
  List<F0956ElementaryCaRule190Variant> get variants => F0956ElementaryCaRule190Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
