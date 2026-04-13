// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0014_sprott_a_presets.dart';
import 'f0014_sprott_a_variants.dart';
import 'f0014_sprott_a_metadata.dart';

/// Sprott A — Strange Attractors.
class F0014SprottA extends AttractorModule {
  F0014SprottA()
      : super(
          id: 'f0014_sprott_a',
          shader: 'shaders/f0014_sprott_a_gpu.frag',
        );

  @override
  F0014SprottAMetadata get metadata => F0014SprottAMetadata.instance;

  @override
  List<F0014SprottAPreset> get presets => F0014SprottAPresets.all;

  @override
  List<F0014SprottAVariant> get variants => F0014SprottAVariants.all;

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
