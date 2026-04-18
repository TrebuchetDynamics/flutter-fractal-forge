// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0817_gaussian_noise_map_presets.dart';
import 'f0817_gaussian_noise_map_variants.dart';
import 'f0817_gaussian_noise_map_metadata.dart';

/// Gaussian Noise Map — Strange Attractors.
class F0817GaussianNoiseMap extends AttractorModule {
  F0817GaussianNoiseMap()
      : super(
          id: 'f0817_gaussian_noise_map',
          shader: 'shaders/f0817_gaussian_noise_map_gpu.frag',
        );

  @override
  F0817GaussianNoiseMapMetadata get metadata => F0817GaussianNoiseMapMetadata.instance;

  @override
  List<F0817GaussianNoiseMapPreset> get presets => F0817GaussianNoiseMapPresets.all;

  @override
  List<F0817GaussianNoiseMapVariant> get variants => F0817GaussianNoiseMapVariants.all;

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
