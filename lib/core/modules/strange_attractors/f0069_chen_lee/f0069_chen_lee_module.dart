// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0069_chen_lee_presets.dart';
import 'f0069_chen_lee_variants.dart';
import 'f0069_chen_lee_metadata.dart';

/// Chen-Lee — Strange Attractors.
class F0069ChenLee extends AttractorModule {
  F0069ChenLee()
      : super(
          id: 'f0069_chen_lee',
          shader: 'shaders/f0069_chen_lee_gpu.frag',
        );

  @override
  F0069ChenLeeMetadata get metadata => F0069ChenLeeMetadata.instance;

  @override
  List<F0069ChenLeePreset> get presets => F0069ChenLeePresets.all;

  @override
  List<F0069ChenLeeVariant> get variants => F0069ChenLeeVariants.all;

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
