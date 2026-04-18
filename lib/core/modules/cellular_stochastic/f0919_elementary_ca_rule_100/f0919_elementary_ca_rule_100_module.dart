// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0919_elementary_ca_rule_100_presets.dart';
import 'f0919_elementary_ca_rule_100_variants.dart';
import 'f0919_elementary_ca_rule_100_metadata.dart';

/// Elementary CA Rule 100 — Cellular & Stochastic.
class F0919ElementaryCaRule100 extends CellularModule {
  F0919ElementaryCaRule100()
      : super(
          id: 'f0919_elementary_ca_rule_100',
          shader: 'shaders/f0919_elementary_ca_rule_100_gpu.frag',
        );

  @override
  F0919ElementaryCaRule100Metadata get metadata => F0919ElementaryCaRule100Metadata.instance;

  @override
  List<F0919ElementaryCaRule100Preset> get presets => F0919ElementaryCaRule100Presets.all;

  @override
  List<F0919ElementaryCaRule100Variant> get variants => F0919ElementaryCaRule100Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
