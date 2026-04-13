// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0031_sprott_r_presets.dart';
import 'f0031_sprott_r_variants.dart';
import 'f0031_sprott_r_metadata.dart';

/// Sprott R — Strange Attractors.
class F0031SprottR extends AttractorModule {
  F0031SprottR()
      : super(
          id: 'f0031_sprott_r',
          shader: 'shaders/f0031_sprott_r_gpu.frag',
        );

  @override
  F0031SprottRMetadata get metadata => F0031SprottRMetadata.instance;

  @override
  List<F0031SprottRPreset> get presets => F0031SprottRPresets.all;

  @override
  List<F0031SprottRVariant> get variants => F0031SprottRVariants.all;

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
