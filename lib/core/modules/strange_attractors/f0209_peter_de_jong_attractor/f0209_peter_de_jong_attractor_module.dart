// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0209_peter_de_jong_attractor_presets.dart';
import 'f0209_peter_de_jong_attractor_variants.dart';
import 'f0209_peter_de_jong_attractor_metadata.dart';

/// Peter de Jong Attractor — Strange Attractors.
class F0209PeterDeJongAttractor extends AttractorModule {
  F0209PeterDeJongAttractor()
      : super(
          id: 'f0209_peter_de_jong_attractor',
          shader: 'shaders/f0209_peter_de_jong_attractor_gpu.frag',
        );

  @override
  F0209PeterDeJongAttractorMetadata get metadata => F0209PeterDeJongAttractorMetadata.instance;

  @override
  List<F0209PeterDeJongAttractorPreset> get presets => F0209PeterDeJongAttractorPresets.all;

  @override
  List<F0209PeterDeJongAttractorVariant> get variants => F0209PeterDeJongAttractorVariants.all;

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
