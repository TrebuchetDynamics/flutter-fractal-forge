// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0224_koch_square_curve_presets.dart';
import 'f0224_koch_square_curve_variants.dart';
import 'f0224_koch_square_curve_metadata.dart';

/// Koch Square Curve — L-Systems & Space-Filling.
class F0224KochSquareCurve extends LSystemModule {
  F0224KochSquareCurve()
      : super(
          id: 'f0224_koch_square_curve',
          shader: 'shaders/f0224_koch_square_curve_gpu.frag',
        );

  @override
  F0224KochSquareCurveMetadata get metadata => F0224KochSquareCurveMetadata.instance;

  @override
  List<F0224KochSquareCurvePreset> get presets => F0224KochSquareCurvePresets.all;

  @override
  List<F0224KochSquareCurveVariant> get variants => F0224KochSquareCurveVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
