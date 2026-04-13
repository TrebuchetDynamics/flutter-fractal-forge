// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0411_gumowski_mira_flowers_presets.dart';
import 'f0411_gumowski_mira_flowers_variants.dart';
import 'f0411_gumowski_mira_flowers_metadata.dart';

/// Gumowski-Mira Flowers — Strange Attractors.
class F0411GumowskiMiraFlowers extends AttractorModule {
  F0411GumowskiMiraFlowers()
      : super(
          id: 'f0411_gumowski_mira_flowers',
          shader: 'shaders/f0411_gumowski_mira_flowers_gpu.frag',
        );

  @override
  F0411GumowskiMiraFlowersMetadata get metadata => F0411GumowskiMiraFlowersMetadata.instance;

  @override
  List<F0411GumowskiMiraFlowersPreset> get presets => F0411GumowskiMiraFlowersPresets.all;

  @override
  List<F0411GumowskiMiraFlowersVariant> get variants => F0411GumowskiMiraFlowersVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
