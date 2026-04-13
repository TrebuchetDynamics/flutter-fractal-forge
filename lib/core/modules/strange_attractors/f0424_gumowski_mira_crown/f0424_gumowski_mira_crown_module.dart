// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0424_gumowski_mira_crown_presets.dart';
import 'f0424_gumowski_mira_crown_variants.dart';
import 'f0424_gumowski_mira_crown_metadata.dart';

/// Gumowski-Mira Crown — Strange Attractors.
class F0424GumowskiMiraCrown extends AttractorModule {
  F0424GumowskiMiraCrown()
      : super(
          id: 'f0424_gumowski_mira_crown',
          shader: 'shaders/f0424_gumowski_mira_crown_gpu.frag',
        );

  @override
  F0424GumowskiMiraCrownMetadata get metadata => F0424GumowskiMiraCrownMetadata.instance;

  @override
  List<F0424GumowskiMiraCrownPreset> get presets => F0424GumowskiMiraCrownPresets.all;

  @override
  List<F0424GumowskiMiraCrownVariant> get variants => F0424GumowskiMiraCrownVariants.all;

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
