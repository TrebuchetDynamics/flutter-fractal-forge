// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0055_halvorsen_attractor_presets.dart';
import 'f0055_halvorsen_attractor_variants.dart';
import 'f0055_halvorsen_attractor_metadata.dart';

/// Halvorsen Attractor — Strange Attractors.
class F0055HalvorsenAttractor extends AttractorModule {
  F0055HalvorsenAttractor()
      : super(
          id: 'f0055_halvorsen_attractor',
          shader: 'shaders/f0055_halvorsen_attractor_gpu.frag',
        );

  @override
  F0055HalvorsenAttractorMetadata get metadata => F0055HalvorsenAttractorMetadata.instance;

  @override
  List<F0055HalvorsenAttractorPreset> get presets => F0055HalvorsenAttractorPresets.all;

  @override
  List<F0055HalvorsenAttractorVariant> get variants => F0055HalvorsenAttractorVariants.all;

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
