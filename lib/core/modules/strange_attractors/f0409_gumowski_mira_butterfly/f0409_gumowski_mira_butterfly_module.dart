// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0409_gumowski_mira_butterfly_presets.dart';
import 'f0409_gumowski_mira_butterfly_variants.dart';
import 'f0409_gumowski_mira_butterfly_metadata.dart';

/// Gumowski-Mira Butterfly — Strange Attractors.
class F0409GumowskiMiraButterfly extends AttractorModule {
  F0409GumowskiMiraButterfly()
      : super(
          id: 'f0409_gumowski_mira_butterfly',
          shader: 'shaders/f0409_gumowski_mira_butterfly_gpu.frag',
        );

  @override
  F0409GumowskiMiraButterflyMetadata get metadata => F0409GumowskiMiraButterflyMetadata.instance;

  @override
  List<F0409GumowskiMiraButterflyPreset> get presets => F0409GumowskiMiraButterflyPresets.all;

  @override
  List<F0409GumowskiMiraButterflyVariant> get variants => F0409GumowskiMiraButterflyVariants.all;

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
