// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0337_rule_184_traffic_presets.dart';
import 'f0337_rule_184_traffic_variants.dart';
import 'f0337_rule_184_traffic_metadata.dart';

/// Rule 184 (Traffic) — Cellular & Stochastic.
class F0337Rule184Traffic extends CellularModule {
  F0337Rule184Traffic()
      : super(
          id: 'f0337_rule_184_traffic',
          shader: 'shaders/f0337_rule_184_traffic_gpu.frag',
        );

  @override
  F0337Rule184TrafficMetadata get metadata => F0337Rule184TrafficMetadata.instance;

  @override
  List<F0337Rule184TrafficPreset> get presets => F0337Rule184TrafficPresets.all;

  @override
  List<F0337Rule184TrafficVariant> get variants => F0337Rule184TrafficVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
