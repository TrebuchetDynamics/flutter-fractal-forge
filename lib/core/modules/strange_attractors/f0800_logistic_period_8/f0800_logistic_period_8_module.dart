// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0800_logistic_period_8_presets.dart';
import 'f0800_logistic_period_8_variants.dart';
import 'f0800_logistic_period_8_metadata.dart';

/// Logistic Period-8 — Strange Attractors.
class F0800LogisticPeriod8 extends AttractorModule {
  F0800LogisticPeriod8()
      : super(
          id: 'f0800_logistic_period_8',
          shader: 'shaders/f0800_logistic_period_8_gpu.frag',
        );

  @override
  F0800LogisticPeriod8Metadata get metadata => F0800LogisticPeriod8Metadata.instance;

  @override
  List<F0800LogisticPeriod8Preset> get presets => F0800LogisticPeriod8Presets.all;

  @override
  List<F0800LogisticPeriod8Variant> get variants => F0800LogisticPeriod8Variants.all;

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
