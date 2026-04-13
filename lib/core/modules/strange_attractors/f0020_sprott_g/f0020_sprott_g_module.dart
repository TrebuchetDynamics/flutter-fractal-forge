// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0020_sprott_g_presets.dart';
import 'f0020_sprott_g_variants.dart';
import 'f0020_sprott_g_metadata.dart';

/// Sprott G — Strange Attractors.
class F0020SprottG extends AttractorModule {
  F0020SprottG()
      : super(
          id: 'f0020_sprott_g',
          shader: 'shaders/f0020_sprott_g_gpu.frag',
        );

  @override
  F0020SprottGMetadata get metadata => F0020SprottGMetadata.instance;

  @override
  List<F0020SprottGPreset> get presets => F0020SprottGPresets.all;

  @override
  List<F0020SprottGVariant> get variants => F0020SprottGVariants.all;

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
