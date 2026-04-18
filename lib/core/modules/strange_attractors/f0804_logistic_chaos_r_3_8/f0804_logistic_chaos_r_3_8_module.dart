// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0804_logistic_chaos_r_3_8_presets.dart';
import 'f0804_logistic_chaos_r_3_8_variants.dart';
import 'f0804_logistic_chaos_r_3_8_metadata.dart';

/// Logistic Chaos r=3.8 — Strange Attractors.
class F0804LogisticChaosR38 extends AttractorModule {
  F0804LogisticChaosR38()
      : super(
          id: 'f0804_logistic_chaos_r_3_8',
          shader: 'shaders/f0804_logistic_chaos_r_3_8_gpu.frag',
        );

  @override
  F0804LogisticChaosR38Metadata get metadata => F0804LogisticChaosR38Metadata.instance;

  @override
  List<F0804LogisticChaosR38Preset> get presets => F0804LogisticChaosR38Presets.all;

  @override
  List<F0804LogisticChaosR38Variant> get variants => F0804LogisticChaosR38Variants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
