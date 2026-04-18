// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0940_elementary_ca_rule_154_presets.dart';
import 'f0940_elementary_ca_rule_154_variants.dart';
import 'f0940_elementary_ca_rule_154_metadata.dart';

/// Elementary CA Rule 154 — Cellular & Stochastic.
class F0940ElementaryCaRule154 extends CellularModule {
  F0940ElementaryCaRule154()
      : super(
          id: 'f0940_elementary_ca_rule_154',
          shader: 'shaders/f0940_elementary_ca_rule_154_gpu.frag',
        );

  @override
  F0940ElementaryCaRule154Metadata get metadata => F0940ElementaryCaRule154Metadata.instance;

  @override
  List<F0940ElementaryCaRule154Preset> get presets => F0940ElementaryCaRule154Presets.all;

  @override
  List<F0940ElementaryCaRule154Variant> get variants => F0940ElementaryCaRule154Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
