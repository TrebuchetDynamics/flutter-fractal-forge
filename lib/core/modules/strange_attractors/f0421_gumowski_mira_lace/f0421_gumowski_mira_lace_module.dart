// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0421_gumowski_mira_lace_presets.dart';
import 'f0421_gumowski_mira_lace_variants.dart';
import 'f0421_gumowski_mira_lace_metadata.dart';

/// Gumowski-Mira Lace — Strange Attractors.
class F0421GumowskiMiraLace extends AttractorModule {
  F0421GumowskiMiraLace()
      : super(
          id: 'f0421_gumowski_mira_lace',
          shader: 'shaders/f0421_gumowski_mira_lace_gpu.frag',
        );

  @override
  F0421GumowskiMiraLaceMetadata get metadata => F0421GumowskiMiraLaceMetadata.instance;

  @override
  List<F0421GumowskiMiraLacePreset> get presets => F0421GumowskiMiraLacePresets.all;

  @override
  List<F0421GumowskiMiraLaceVariant> get variants => F0421GumowskiMiraLaceVariants.all;

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
