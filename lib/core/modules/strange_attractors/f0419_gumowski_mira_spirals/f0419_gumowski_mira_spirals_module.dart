// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0419_gumowski_mira_spirals_presets.dart';
import 'f0419_gumowski_mira_spirals_variants.dart';
import 'f0419_gumowski_mira_spirals_metadata.dart';

/// Gumowski-Mira Spirals — Strange Attractors.
class F0419GumowskiMiraSpirals extends AttractorModule {
  F0419GumowskiMiraSpirals()
      : super(
          id: 'f0419_gumowski_mira_spirals',
          shader: 'shaders/f0419_gumowski_mira_spirals_gpu.frag',
        );

  @override
  F0419GumowskiMiraSpiralsMetadata get metadata => F0419GumowskiMiraSpiralsMetadata.instance;

  @override
  List<F0419GumowskiMiraSpiralsPreset> get presets => F0419GumowskiMiraSpiralsPresets.all;

  @override
  List<F0419GumowskiMiraSpiralsVariant> get variants => F0419GumowskiMiraSpiralsVariants.all;

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
