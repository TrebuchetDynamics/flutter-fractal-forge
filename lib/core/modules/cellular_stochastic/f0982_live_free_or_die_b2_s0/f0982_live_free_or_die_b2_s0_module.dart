// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0982_live_free_or_die_b2_s0_presets.dart';
import 'f0982_live_free_or_die_b2_s0_variants.dart';
import 'f0982_live_free_or_die_b2_s0_metadata.dart';

/// Live Free or Die (B2/S0) — Cellular & Stochastic.
class F0982LiveFreeOrDieB2S0 extends CellularModule {
  F0982LiveFreeOrDieB2S0()
      : super(
          id: 'f0982_live_free_or_die_b2_s0',
          shader: 'shaders/f0982_live_free_or_die_b2_s0_gpu.frag',
        );

  @override
  F0982LiveFreeOrDieB2S0Metadata get metadata => F0982LiveFreeOrDieB2S0Metadata.instance;

  @override
  List<F0982LiveFreeOrDieB2S0Preset> get presets => F0982LiveFreeOrDieB2S0Presets.all;

  @override
  List<F0982LiveFreeOrDieB2S0Variant> get variants => F0982LiveFreeOrDieB2S0Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
