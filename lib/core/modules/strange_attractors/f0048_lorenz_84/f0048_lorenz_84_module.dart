// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0048_lorenz_84_presets.dart';
import 'f0048_lorenz_84_variants.dart';
import 'f0048_lorenz_84_metadata.dart';

/// Lorenz-84 — Strange Attractors.
class F0048Lorenz84 extends AttractorModule {
  F0048Lorenz84()
      : super(
          id: 'f0048_lorenz_84',
          shader: 'shaders/f0048_lorenz_84_gpu.frag',
        );

  @override
  F0048Lorenz84Metadata get metadata => F0048Lorenz84Metadata.instance;

  @override
  List<F0048Lorenz84Preset> get presets => F0048Lorenz84Presets.all;

  @override
  List<F0048Lorenz84Variant> get variants => F0048Lorenz84Variants.all;

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
