// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0798_logistic_period_2_presets.dart';
import 'f0798_logistic_period_2_variants.dart';
import 'f0798_logistic_period_2_metadata.dart';

/// Logistic Period-2 — Strange Attractors.
class F0798LogisticPeriod2 extends AttractorModule {
  F0798LogisticPeriod2()
      : super(
          id: 'f0798_logistic_period_2',
          shader: 'shaders/f0798_logistic_period_2_gpu.frag',
        );

  @override
  F0798LogisticPeriod2Metadata get metadata => F0798LogisticPeriod2Metadata.instance;

  @override
  List<F0798LogisticPeriod2Preset> get presets => F0798LogisticPeriod2Presets.all;

  @override
  List<F0798LogisticPeriod2Variant> get variants => F0798LogisticPeriod2Variants.all;

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
