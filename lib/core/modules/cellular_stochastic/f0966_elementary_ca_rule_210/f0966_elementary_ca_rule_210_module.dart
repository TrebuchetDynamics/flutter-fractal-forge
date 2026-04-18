// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0966_elementary_ca_rule_210_presets.dart';
import 'f0966_elementary_ca_rule_210_variants.dart';
import 'f0966_elementary_ca_rule_210_metadata.dart';

/// Elementary CA Rule 210 — Cellular & Stochastic.
class F0966ElementaryCaRule210 extends CellularModule {
  F0966ElementaryCaRule210()
      : super(
          id: 'f0966_elementary_ca_rule_210',
          shader: 'shaders/f0966_elementary_ca_rule_210_gpu.frag',
        );

  @override
  F0966ElementaryCaRule210Metadata get metadata => F0966ElementaryCaRule210Metadata.instance;

  @override
  List<F0966ElementaryCaRule210Preset> get presets => F0966ElementaryCaRule210Presets.all;

  @override
  List<F0966ElementaryCaRule210Variant> get variants => F0966ElementaryCaRule210Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
