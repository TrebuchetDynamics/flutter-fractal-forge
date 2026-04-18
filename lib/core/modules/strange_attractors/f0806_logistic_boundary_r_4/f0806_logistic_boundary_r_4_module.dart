// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0806_logistic_boundary_r_4_presets.dart';
import 'f0806_logistic_boundary_r_4_variants.dart';
import 'f0806_logistic_boundary_r_4_metadata.dart';

/// Logistic Boundary r=4 — Strange Attractors.
class F0806LogisticBoundaryR4 extends AttractorModule {
  F0806LogisticBoundaryR4()
      : super(
          id: 'f0806_logistic_boundary_r_4',
          shader: 'shaders/f0806_logistic_boundary_r_4_gpu.frag',
        );

  @override
  F0806LogisticBoundaryR4Metadata get metadata => F0806LogisticBoundaryR4Metadata.instance;

  @override
  List<F0806LogisticBoundaryR4Preset> get presets => F0806LogisticBoundaryR4Presets.all;

  @override
  List<F0806LogisticBoundaryR4Variant> get variants => F0806LogisticBoundaryR4Variants.all;

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
