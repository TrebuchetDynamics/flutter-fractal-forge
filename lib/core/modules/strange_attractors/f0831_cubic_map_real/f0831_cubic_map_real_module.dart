// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0831_cubic_map_real_presets.dart';
import 'f0831_cubic_map_real_variants.dart';
import 'f0831_cubic_map_real_metadata.dart';

/// Cubic Map (Real) — Strange Attractors.
class F0831CubicMapReal extends AttractorModule {
  F0831CubicMapReal()
      : super(
          id: 'f0831_cubic_map_real',
          shader: 'shaders/f0831_cubic_map_real_gpu.frag',
        );

  @override
  F0831CubicMapRealMetadata get metadata => F0831CubicMapRealMetadata.instance;

  @override
  List<F0831CubicMapRealPreset> get presets => F0831CubicMapRealPresets.all;

  @override
  List<F0831CubicMapRealVariant> get variants => F0831CubicMapRealVariants.all;

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
