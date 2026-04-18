// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0823_standard_map_k_6_0_presets.dart';
import 'f0823_standard_map_k_6_0_variants.dart';
import 'f0823_standard_map_k_6_0_metadata.dart';

/// Standard Map K=6.0 — Strange Attractors.
class F0823StandardMapK60 extends AttractorModule {
  F0823StandardMapK60()
      : super(
          id: 'f0823_standard_map_k_6_0',
          shader: 'shaders/f0823_standard_map_k_6_0_gpu.frag',
        );

  @override
  F0823StandardMapK60Metadata get metadata => F0823StandardMapK60Metadata.instance;

  @override
  List<F0823StandardMapK60Preset> get presets => F0823StandardMapK60Presets.all;

  @override
  List<F0823StandardMapK60Variant> get variants => F0823StandardMapK60Variants.all;

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
