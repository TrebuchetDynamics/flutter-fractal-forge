// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0018_sprott_e_presets.dart';
import 'f0018_sprott_e_variants.dart';
import 'f0018_sprott_e_metadata.dart';

/// Sprott E — Strange Attractors.
class F0018SprottE extends AttractorModule {
  F0018SprottE()
      : super(
          id: 'f0018_sprott_e',
          shader: 'shaders/f0018_sprott_e_gpu.frag',
        );

  @override
  F0018SprottEMetadata get metadata => F0018SprottEMetadata.instance;

  @override
  List<F0018SprottEPreset> get presets => F0018SprottEPresets.all;

  @override
  List<F0018SprottEVariant> get variants => F0018SprottEVariants.all;

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
