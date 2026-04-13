// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0028_sprott_o_presets.dart';
import 'f0028_sprott_o_variants.dart';
import 'f0028_sprott_o_metadata.dart';

/// Sprott O — Strange Attractors.
class F0028SprottO extends AttractorModule {
  F0028SprottO()
      : super(
          id: 'f0028_sprott_o',
          shader: 'shaders/f0028_sprott_o_gpu.frag',
        );

  @override
  F0028SprottOMetadata get metadata => F0028SprottOMetadata.instance;

  @override
  List<F0028SprottOPreset> get presets => F0028SprottOPresets.all;

  @override
  List<F0028SprottOVariant> get variants => F0028SprottOVariants.all;

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
