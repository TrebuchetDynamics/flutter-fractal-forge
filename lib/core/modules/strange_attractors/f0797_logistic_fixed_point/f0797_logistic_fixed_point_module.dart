// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0797_logistic_fixed_point_presets.dart';
import 'f0797_logistic_fixed_point_variants.dart';
import 'f0797_logistic_fixed_point_metadata.dart';

/// Logistic Fixed Point — Strange Attractors.
class F0797LogisticFixedPoint extends AttractorModule {
  F0797LogisticFixedPoint()
      : super(
          id: 'f0797_logistic_fixed_point',
          shader: 'shaders/f0797_logistic_fixed_point_gpu.frag',
        );

  @override
  F0797LogisticFixedPointMetadata get metadata => F0797LogisticFixedPointMetadata.instance;

  @override
  List<F0797LogisticFixedPointPreset> get presets => F0797LogisticFixedPointPresets.all;

  @override
  List<F0797LogisticFixedPointVariant> get variants => F0797LogisticFixedPointVariants.all;

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
