// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0226_quadratic_koch_curve_type_2_presets.dart';
import 'f0226_quadratic_koch_curve_type_2_variants.dart';
import 'f0226_quadratic_koch_curve_type_2_metadata.dart';

/// Quadratic Koch Curve (Type 2) — L-Systems & Space-Filling.
class F0226QuadraticKochCurveType2 extends LSystemModule {
  F0226QuadraticKochCurveType2()
      : super(
          id: 'f0226_quadratic_koch_curve_type_2',
          shader: 'shaders/f0226_quadratic_koch_curve_type_2_gpu.frag',
        );

  @override
  F0226QuadraticKochCurveType2Metadata get metadata => F0226QuadraticKochCurveType2Metadata.instance;

  @override
  List<F0226QuadraticKochCurveType2Preset> get presets => F0226QuadraticKochCurveType2Presets.all;

  @override
  List<F0226QuadraticKochCurveType2Variant> get variants => F0226QuadraticKochCurveType2Variants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
