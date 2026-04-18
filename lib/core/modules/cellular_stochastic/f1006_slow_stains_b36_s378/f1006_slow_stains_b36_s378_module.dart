// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1006_slow_stains_b36_s378_presets.dart';
import 'f1006_slow_stains_b36_s378_variants.dart';
import 'f1006_slow_stains_b36_s378_metadata.dart';

/// Slow Stains (B36/S378) — Cellular & Stochastic.
class F1006SlowStainsB36S378 extends CellularModule {
  F1006SlowStainsB36S378()
      : super(
          id: 'f1006_slow_stains_b36_s378',
          shader: 'shaders/f1006_slow_stains_b36_s378_gpu.frag',
        );

  @override
  F1006SlowStainsB36S378Metadata get metadata => F1006SlowStainsB36S378Metadata.instance;

  @override
  List<F1006SlowStainsB36S378Preset> get presets => F1006SlowStainsB36S378Presets.all;

  @override
  List<F1006SlowStainsB36S378Variant> get variants => F1006SlowStainsB36S378Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
