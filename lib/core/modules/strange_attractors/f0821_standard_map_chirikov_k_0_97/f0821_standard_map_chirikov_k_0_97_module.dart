// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0821_standard_map_chirikov_k_0_97_presets.dart';
import 'f0821_standard_map_chirikov_k_0_97_variants.dart';
import 'f0821_standard_map_chirikov_k_0_97_metadata.dart';

/// Standard Map (Chirikov K=0.97) — Strange Attractors.
class F0821StandardMapChirikovK097 extends AttractorModule {
  F0821StandardMapChirikovK097()
      : super(
          id: 'f0821_standard_map_chirikov_k_0_97',
          shader: 'shaders/f0821_standard_map_chirikov_k_0_97_gpu.frag',
        );

  @override
  F0821StandardMapChirikovK097Metadata get metadata => F0821StandardMapChirikovK097Metadata.instance;

  @override
  List<F0821StandardMapChirikovK097Preset> get presets => F0821StandardMapChirikovK097Presets.all;

  @override
  List<F0821StandardMapChirikovK097Variant> get variants => F0821StandardMapChirikovK097Variants.all;

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
