// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0225_quadratic_koch_curve_type_1_presets.dart';
import 'f0225_quadratic_koch_curve_type_1_variants.dart';
import 'f0225_quadratic_koch_curve_type_1_metadata.dart';

/// Quadratic Koch Curve (Type 1) — L-Systems & Space-Filling.
class F0225QuadraticKochCurveType1 extends LSystemModule {
  F0225QuadraticKochCurveType1()
      : super(
          id: 'f0225_quadratic_koch_curve_type_1',
          shader: 'shaders/f0225_quadratic_koch_curve_type_1_gpu.frag',
        );

  @override
  F0225QuadraticKochCurveType1Metadata get metadata => F0225QuadraticKochCurveType1Metadata.instance;

  @override
  List<F0225QuadraticKochCurveType1Preset> get presets => F0225QuadraticKochCurveType1Presets.all;

  @override
  List<F0225QuadraticKochCurveType1Variant> get variants => F0225QuadraticKochCurveType1Variants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
