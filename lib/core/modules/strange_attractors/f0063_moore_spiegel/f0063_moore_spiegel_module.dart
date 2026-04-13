// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0063_moore_spiegel_presets.dart';
import 'f0063_moore_spiegel_variants.dart';
import 'f0063_moore_spiegel_metadata.dart';

/// Moore-Spiegel — Strange Attractors.
class F0063MooreSpiegel extends AttractorModule {
  F0063MooreSpiegel()
      : super(
          id: 'f0063_moore_spiegel',
          shader: 'shaders/f0063_moore_spiegel_gpu.frag',
        );

  @override
  F0063MooreSpiegelMetadata get metadata => F0063MooreSpiegelMetadata.instance;

  @override
  List<F0063MooreSpiegelPreset> get presets => F0063MooreSpiegelPresets.all;

  @override
  List<F0063MooreSpiegelVariant> get variants => F0063MooreSpiegelVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
