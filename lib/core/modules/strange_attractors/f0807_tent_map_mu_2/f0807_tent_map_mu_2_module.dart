// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0807_tent_map_mu_2_presets.dart';
import 'f0807_tent_map_mu_2_variants.dart';
import 'f0807_tent_map_mu_2_metadata.dart';

/// Tent Map (mu=2) — Strange Attractors.
class F0807TentMapMu2 extends AttractorModule {
  F0807TentMapMu2()
      : super(
          id: 'f0807_tent_map_mu_2',
          shader: 'shaders/f0807_tent_map_mu_2_gpu.frag',
        );

  @override
  F0807TentMapMu2Metadata get metadata => F0807TentMapMu2Metadata.instance;

  @override
  List<F0807TentMapMu2Preset> get presets => F0807TentMapMu2Presets.all;

  @override
  List<F0807TentMapMu2Variant> get variants => F0807TentMapMu2Variants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
