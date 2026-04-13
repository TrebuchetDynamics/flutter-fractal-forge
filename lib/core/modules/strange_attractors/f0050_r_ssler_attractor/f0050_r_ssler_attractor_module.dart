// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0050_r_ssler_attractor_presets.dart';
import 'f0050_r_ssler_attractor_variants.dart';
import 'f0050_r_ssler_attractor_metadata.dart';

/// Rössler Attractor — Strange Attractors.
class F0050RSslerAttractor extends AttractorModule {
  F0050RSslerAttractor()
      : super(
          id: 'f0050_r_ssler_attractor',
          shader: 'shaders/f0050_r_ssler_attractor_gpu.frag',
        );

  @override
  F0050RSslerAttractorMetadata get metadata => F0050RSslerAttractorMetadata.instance;

  @override
  List<F0050RSslerAttractorPreset> get presets => F0050RSslerAttractorPresets.all;

  @override
  List<F0050RSslerAttractorVariant> get variants => F0050RSslerAttractorVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
