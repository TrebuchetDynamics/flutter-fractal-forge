// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0077_bouali_attractor_presets.dart';
import 'f0077_bouali_attractor_variants.dart';
import 'f0077_bouali_attractor_metadata.dart';

/// Bouali Attractor — Strange Attractors.
class F0077BoualiAttractor extends AttractorModule {
  F0077BoualiAttractor()
      : super(
          id: 'f0077_bouali_attractor',
          shader: 'shaders/f0077_bouali_attractor_gpu.frag',
        );

  @override
  F0077BoualiAttractorMetadata get metadata => F0077BoualiAttractorMetadata.instance;

  @override
  List<F0077BoualiAttractorPreset> get presets => F0077BoualiAttractorPresets.all;

  @override
  List<F0077BoualiAttractorVariant> get variants => F0077BoualiAttractorVariants.all;

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
