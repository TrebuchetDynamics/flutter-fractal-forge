// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0814_quadratic_map_c_1_4_presets.dart';
import 'f0814_quadratic_map_c_1_4_variants.dart';
import 'f0814_quadratic_map_c_1_4_metadata.dart';

/// Quadratic Map c=-1.4 — Strange Attractors.
class F0814QuadraticMapC14 extends AttractorModule {
  F0814QuadraticMapC14()
      : super(
          id: 'f0814_quadratic_map_c_1_4',
          shader: 'shaders/f0814_quadratic_map_c_1_4_gpu.frag',
        );

  @override
  F0814QuadraticMapC14Metadata get metadata => F0814QuadraticMapC14Metadata.instance;

  @override
  List<F0814QuadraticMapC14Preset> get presets => F0814QuadraticMapC14Presets.all;

  @override
  List<F0814QuadraticMapC14Variant> get variants => F0814QuadraticMapC14Variants.all;

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
