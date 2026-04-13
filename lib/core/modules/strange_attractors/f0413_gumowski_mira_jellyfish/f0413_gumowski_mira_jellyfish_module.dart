// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0413_gumowski_mira_jellyfish_presets.dart';
import 'f0413_gumowski_mira_jellyfish_variants.dart';
import 'f0413_gumowski_mira_jellyfish_metadata.dart';

/// Gumowski-Mira Jellyfish — Strange Attractors.
class F0413GumowskiMiraJellyfish extends AttractorModule {
  F0413GumowskiMiraJellyfish()
      : super(
          id: 'f0413_gumowski_mira_jellyfish',
          shader: 'shaders/f0413_gumowski_mira_jellyfish_gpu.frag',
        );

  @override
  F0413GumowskiMiraJellyfishMetadata get metadata => F0413GumowskiMiraJellyfishMetadata.instance;

  @override
  List<F0413GumowskiMiraJellyfishPreset> get presets => F0413GumowskiMiraJellyfishPresets.all;

  @override
  List<F0413GumowskiMiraJellyfishVariant> get variants => F0413GumowskiMiraJellyfishVariants.all;

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
