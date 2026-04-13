// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0067_arneodo_attractor_presets.dart';
import 'f0067_arneodo_attractor_variants.dart';
import 'f0067_arneodo_attractor_metadata.dart';

/// Arneodo Attractor — Strange Attractors.
class F0067ArneodoAttractor extends AttractorModule {
  F0067ArneodoAttractor()
      : super(
          id: 'f0067_arneodo_attractor',
          shader: 'shaders/f0067_arneodo_attractor_gpu.frag',
        );

  @override
  F0067ArneodoAttractorMetadata get metadata => F0067ArneodoAttractorMetadata.instance;

  @override
  List<F0067ArneodoAttractorPreset> get presets => F0067ArneodoAttractorPresets.all;

  @override
  List<F0067ArneodoAttractorVariant> get variants => F0067ArneodoAttractorVariants.all;

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
