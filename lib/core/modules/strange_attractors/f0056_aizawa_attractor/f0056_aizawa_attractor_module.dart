// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0056_aizawa_attractor_presets.dart';
import 'f0056_aizawa_attractor_variants.dart';
import 'f0056_aizawa_attractor_metadata.dart';

/// Aizawa Attractor — Strange Attractors.
class F0056AizawaAttractor extends AttractorModule {
  F0056AizawaAttractor()
      : super(
          id: 'f0056_aizawa_attractor',
          shader: 'shaders/f0056_aizawa_attractor_gpu.frag',
        );

  @override
  F0056AizawaAttractorMetadata get metadata => F0056AizawaAttractorMetadata.instance;

  @override
  List<F0056AizawaAttractorPreset> get presets => F0056AizawaAttractorPresets.all;

  @override
  List<F0056AizawaAttractorVariant> get variants => F0056AizawaAttractorVariants.all;

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
