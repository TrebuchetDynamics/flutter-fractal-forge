// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0805_logistic_periodic_window_r_3_83_presets.dart';
import 'f0805_logistic_periodic_window_r_3_83_variants.dart';
import 'f0805_logistic_periodic_window_r_3_83_metadata.dart';

/// Logistic Periodic Window r=3.83 — Strange Attractors.
class F0805LogisticPeriodicWindowR383 extends AttractorModule {
  F0805LogisticPeriodicWindowR383()
      : super(
          id: 'f0805_logistic_periodic_window_r_3_83',
          shader: 'shaders/f0805_logistic_periodic_window_r_3_83_gpu.frag',
        );

  @override
  F0805LogisticPeriodicWindowR383Metadata get metadata => F0805LogisticPeriodicWindowR383Metadata.instance;

  @override
  List<F0805LogisticPeriodicWindowR383Preset> get presets => F0805LogisticPeriodicWindowR383Presets.all;

  @override
  List<F0805LogisticPeriodicWindowR383Variant> get variants => F0805LogisticPeriodicWindowR383Variants.all;

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
