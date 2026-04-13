// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0221_cubic_map_2d_presets.dart';
import 'f0221_cubic_map_2d_variants.dart';
import 'f0221_cubic_map_2d_metadata.dart';

/// Cubic Map 2D — Strange Attractors.
class F0221CubicMap2d extends AttractorModule {
  F0221CubicMap2d()
      : super(
          id: 'f0221_cubic_map_2d',
          shader: 'shaders/f0221_cubic_map_2d_gpu.frag',
        );

  @override
  F0221CubicMap2dMetadata get metadata => F0221CubicMap2dMetadata.instance;

  @override
  List<F0221CubicMap2dPreset> get presets => F0221CubicMap2dPresets.all;

  @override
  List<F0221CubicMap2dVariant> get variants => F0221CubicMap2dVariants.all;

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
