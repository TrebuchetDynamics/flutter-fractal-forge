// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1083_bogdanov_period_4_presets.dart';
import 'f1083_bogdanov_period_4_variants.dart';
import 'f1083_bogdanov_period_4_metadata.dart';

/// Bogdanov Period 4 — Strange Attractors.
class F1083BogdanovPeriod4 extends AttractorModule {
  F1083BogdanovPeriod4()
      : super(
          id: 'f1083_bogdanov_period_4',
          shader: 'shaders/f1083_bogdanov_period_4_gpu.frag',
        );

  @override
  F1083BogdanovPeriod4Metadata get metadata => F1083BogdanovPeriod4Metadata.instance;

  @override
  List<F1083BogdanovPeriod4Preset> get presets => F1083BogdanovPeriod4Presets.all;

  @override
  List<F1083BogdanovPeriod4Variant> get variants => F1083BogdanovPeriod4Variants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
