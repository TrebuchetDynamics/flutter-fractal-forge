// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0039_sprott_linz_g_presets.dart';
import 'f0039_sprott_linz_g_variants.dart';
import 'f0039_sprott_linz_g_metadata.dart';

/// Sprott-Linz G — Strange Attractors.
class F0039SprottLinzG extends AttractorModule {
  F0039SprottLinzG()
      : super(
          id: 'f0039_sprott_linz_g',
          shader: 'shaders/f0039_sprott_linz_g_gpu.frag',
        );

  @override
  F0039SprottLinzGMetadata get metadata => F0039SprottLinzGMetadata.instance;

  @override
  List<F0039SprottLinzGPreset> get presets => F0039SprottLinzGPresets.all;

  @override
  List<F0039SprottLinzGVariant> get variants => F0039SprottLinzGVariants.all;

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
