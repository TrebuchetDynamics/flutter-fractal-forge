// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0212_standard_map_chirikov_presets.dart';
import 'f0212_standard_map_chirikov_variants.dart';
import 'f0212_standard_map_chirikov_metadata.dart';

/// Standard Map (Chirikov) — Strange Attractors.
class F0212StandardMapChirikov extends AttractorModule {
  F0212StandardMapChirikov()
      : super(
          id: 'f0212_standard_map_chirikov',
          shader: 'shaders/f0212_standard_map_chirikov_gpu.frag',
        );

  @override
  F0212StandardMapChirikovMetadata get metadata => F0212StandardMapChirikovMetadata.instance;

  @override
  List<F0212StandardMapChirikovPreset> get presets => F0212StandardMapChirikovPresets.all;

  @override
  List<F0212StandardMapChirikovVariant> get variants => F0212StandardMapChirikovVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
