// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0085_langford_attractor_presets.dart';
import 'f0085_langford_attractor_variants.dart';
import 'f0085_langford_attractor_metadata.dart';

/// Langford Attractor — Strange Attractors.
class F0085LangfordAttractor extends AttractorModule {
  F0085LangfordAttractor()
      : super(
          id: 'f0085_langford_attractor',
          shader: 'shaders/f0085_langford_attractor_gpu.frag',
        );

  @override
  F0085LangfordAttractorMetadata get metadata => F0085LangfordAttractorMetadata.instance;

  @override
  List<F0085LangfordAttractorPreset> get presets => F0085LangfordAttractorPresets.all;

  @override
  List<F0085LangfordAttractorVariant> get variants => F0085LangfordAttractorVariants.all;

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
