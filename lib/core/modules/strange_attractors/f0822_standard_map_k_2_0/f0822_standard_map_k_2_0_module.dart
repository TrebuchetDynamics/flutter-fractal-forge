// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0822_standard_map_k_2_0_presets.dart';
import 'f0822_standard_map_k_2_0_variants.dart';
import 'f0822_standard_map_k_2_0_metadata.dart';

/// Standard Map K=2.0 — Strange Attractors.
class F0822StandardMapK20 extends AttractorModule {
  F0822StandardMapK20()
      : super(
          id: 'f0822_standard_map_k_2_0',
          shader: 'shaders/f0822_standard_map_k_2_0_gpu.frag',
        );

  @override
  F0822StandardMapK20Metadata get metadata => F0822StandardMapK20Metadata.instance;

  @override
  List<F0822StandardMapK20Preset> get presets => F0822StandardMapK20Presets.all;

  @override
  List<F0822StandardMapK20Variant> get variants => F0822StandardMapK20Variants.all;

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
