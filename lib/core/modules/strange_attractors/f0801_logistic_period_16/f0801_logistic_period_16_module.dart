// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0801_logistic_period_16_presets.dart';
import 'f0801_logistic_period_16_variants.dart';
import 'f0801_logistic_period_16_metadata.dart';

/// Logistic Period-16 — Strange Attractors.
class F0801LogisticPeriod16 extends AttractorModule {
  F0801LogisticPeriod16()
      : super(
          id: 'f0801_logistic_period_16',
          shader: 'shaders/f0801_logistic_period_16_gpu.frag',
        );

  @override
  F0801LogisticPeriod16Metadata get metadata => F0801LogisticPeriod16Metadata.instance;

  @override
  List<F0801LogisticPeriod16Preset> get presets => F0801LogisticPeriod16Presets.all;

  @override
  List<F0801LogisticPeriod16Variant> get variants => F0801LogisticPeriod16Variants.all;

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
