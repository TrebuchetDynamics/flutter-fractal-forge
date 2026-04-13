// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0065_rucklidge_attractor_presets.dart';
import 'f0065_rucklidge_attractor_variants.dart';
import 'f0065_rucklidge_attractor_metadata.dart';

/// Rucklidge Attractor — Strange Attractors.
class F0065RucklidgeAttractor extends AttractorModule {
  F0065RucklidgeAttractor()
      : super(
          id: 'f0065_rucklidge_attractor',
          shader: 'shaders/f0065_rucklidge_attractor_gpu.frag',
        );

  @override
  F0065RucklidgeAttractorMetadata get metadata => F0065RucklidgeAttractorMetadata.instance;

  @override
  List<F0065RucklidgeAttractorPreset> get presets => F0065RucklidgeAttractorPresets.all;

  @override
  List<F0065RucklidgeAttractorVariant> get variants => F0065RucklidgeAttractorVariants.all;

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
