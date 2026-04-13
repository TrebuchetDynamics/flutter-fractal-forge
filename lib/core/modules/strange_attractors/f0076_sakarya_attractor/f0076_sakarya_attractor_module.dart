// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0076_sakarya_attractor_presets.dart';
import 'f0076_sakarya_attractor_variants.dart';
import 'f0076_sakarya_attractor_metadata.dart';

/// Sakarya Attractor — Strange Attractors.
class F0076SakaryaAttractor extends AttractorModule {
  F0076SakaryaAttractor()
      : super(
          id: 'f0076_sakarya_attractor',
          shader: 'shaders/f0076_sakarya_attractor_gpu.frag',
        );

  @override
  F0076SakaryaAttractorMetadata get metadata => F0076SakaryaAttractorMetadata.instance;

  @override
  List<F0076SakaryaAttractorPreset> get presets => F0076SakaryaAttractorPresets.all;

  @override
  List<F0076SakaryaAttractorVariant> get variants => F0076SakaryaAttractorVariants.all;

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
