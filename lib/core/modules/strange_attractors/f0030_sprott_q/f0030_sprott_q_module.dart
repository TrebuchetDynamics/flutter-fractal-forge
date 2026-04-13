// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0030_sprott_q_presets.dart';
import 'f0030_sprott_q_variants.dart';
import 'f0030_sprott_q_metadata.dart';

/// Sprott Q — Strange Attractors.
class F0030SprottQ extends AttractorModule {
  F0030SprottQ()
      : super(
          id: 'f0030_sprott_q',
          shader: 'shaders/f0030_sprott_q_gpu.frag',
        );

  @override
  F0030SprottQMetadata get metadata => F0030SprottQMetadata.instance;

  @override
  List<F0030SprottQPreset> get presets => F0030SprottQPresets.all;

  @override
  List<F0030SprottQVariant> get variants => F0030SprottQVariants.all;

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
