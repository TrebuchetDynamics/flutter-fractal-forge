// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0023_sprott_j_presets.dart';
import 'f0023_sprott_j_variants.dart';
import 'f0023_sprott_j_metadata.dart';

/// Sprott J — Strange Attractors.
class F0023SprottJ extends AttractorModule {
  F0023SprottJ()
      : super(
          id: 'f0023_sprott_j',
          shader: 'shaders/f0023_sprott_j_gpu.frag',
        );

  @override
  F0023SprottJMetadata get metadata => F0023SprottJMetadata.instance;

  @override
  List<F0023SprottJPreset> get presets => F0023SprottJPresets.all;

  @override
  List<F0023SprottJVariant> get variants => F0023SprottJVariants.all;

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
