// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0815_quadratic_map_c_2_0_presets.dart';
import 'f0815_quadratic_map_c_2_0_variants.dart';
import 'f0815_quadratic_map_c_2_0_metadata.dart';

/// Quadratic Map c=-2.0 — Strange Attractors.
class F0815QuadraticMapC20 extends AttractorModule {
  F0815QuadraticMapC20()
      : super(
          id: 'f0815_quadratic_map_c_2_0',
          shader: 'shaders/f0815_quadratic_map_c_2_0_gpu.frag',
        );

  @override
  F0815QuadraticMapC20Metadata get metadata => F0815QuadraticMapC20Metadata.instance;

  @override
  List<F0815QuadraticMapC20Preset> get presets => F0815QuadraticMapC20Presets.all;

  @override
  List<F0815QuadraticMapC20Variant> get variants => F0815QuadraticMapC20Variants.all;

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
