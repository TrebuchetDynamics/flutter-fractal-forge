// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0803_logistic_chaos_r_3_7_presets.dart';
import 'f0803_logistic_chaos_r_3_7_variants.dart';
import 'f0803_logistic_chaos_r_3_7_metadata.dart';

/// Logistic Chaos r=3.7 — Strange Attractors.
class F0803LogisticChaosR37 extends AttractorModule {
  F0803LogisticChaosR37()
      : super(
          id: 'f0803_logistic_chaos_r_3_7',
          shader: 'shaders/f0803_logistic_chaos_r_3_7_gpu.frag',
        );

  @override
  F0803LogisticChaosR37Metadata get metadata => F0803LogisticChaosR37Metadata.instance;

  @override
  List<F0803LogisticChaosR37Preset> get presets => F0803LogisticChaosR37Presets.all;

  @override
  List<F0803LogisticChaosR37Variant> get variants => F0803LogisticChaosR37Variants.all;

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
