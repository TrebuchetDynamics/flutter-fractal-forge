// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0949_elementary_ca_rule_172_presets.dart';
import 'f0949_elementary_ca_rule_172_variants.dart';
import 'f0949_elementary_ca_rule_172_metadata.dart';

/// Elementary CA Rule 172 — Cellular & Stochastic.
class F0949ElementaryCaRule172 extends CellularModule {
  F0949ElementaryCaRule172()
      : super(
          id: 'f0949_elementary_ca_rule_172',
          shader: 'shaders/f0949_elementary_ca_rule_172_gpu.frag',
        );

  @override
  F0949ElementaryCaRule172Metadata get metadata => F0949ElementaryCaRule172Metadata.instance;

  @override
  List<F0949ElementaryCaRule172Preset> get presets => F0949ElementaryCaRule172Presets.all;

  @override
  List<F0949ElementaryCaRule172Variant> get variants => F0949ElementaryCaRule172Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
