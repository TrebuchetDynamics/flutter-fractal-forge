// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0808_tent_map_mu_1_5_presets.dart';
import 'f0808_tent_map_mu_1_5_variants.dart';
import 'f0808_tent_map_mu_1_5_metadata.dart';

/// Tent Map (mu=1.5) — Strange Attractors.
class F0808TentMapMu15 extends AttractorModule {
  F0808TentMapMu15()
      : super(
          id: 'f0808_tent_map_mu_1_5',
          shader: 'shaders/f0808_tent_map_mu_1_5_gpu.frag',
        );

  @override
  F0808TentMapMu15Metadata get metadata => F0808TentMapMu15Metadata.instance;

  @override
  List<F0808TentMapMu15Preset> get presets => F0808TentMapMu15Presets.all;

  @override
  List<F0808TentMapMu15Variant> get variants => F0808TentMapMu15Variants.all;

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
