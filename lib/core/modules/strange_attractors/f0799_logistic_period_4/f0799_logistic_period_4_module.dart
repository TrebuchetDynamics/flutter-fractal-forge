// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0799_logistic_period_4_presets.dart';
import 'f0799_logistic_period_4_variants.dart';
import 'f0799_logistic_period_4_metadata.dart';

/// Logistic Period-4 — Strange Attractors.
class F0799LogisticPeriod4 extends AttractorModule {
  F0799LogisticPeriod4()
      : super(
          id: 'f0799_logistic_period_4',
          shader: 'shaders/f0799_logistic_period_4_gpu.frag',
        );

  @override
  F0799LogisticPeriod4Metadata get metadata => F0799LogisticPeriod4Metadata.instance;

  @override
  List<F0799LogisticPeriod4Preset> get presets => F0799LogisticPeriod4Presets.all;

  @override
  List<F0799LogisticPeriod4Variant> get variants => F0799LogisticPeriod4Variants.all;

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
