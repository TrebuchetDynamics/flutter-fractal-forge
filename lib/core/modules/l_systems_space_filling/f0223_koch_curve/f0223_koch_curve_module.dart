// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0223_koch_curve_presets.dart';
import 'f0223_koch_curve_variants.dart';
import 'f0223_koch_curve_metadata.dart';

/// Koch Curve — L-Systems & Space-Filling.
class F0223KochCurve extends LSystemModule {
  F0223KochCurve()
      : super(
          id: 'f0223_koch_curve',
          shader: 'shaders/f0223_koch_curve_gpu.frag',
        );

  @override
  F0223KochCurveMetadata get metadata => F0223KochCurveMetadata.instance;

  @override
  List<F0223KochCurvePreset> get presets => F0223KochCurvePresets.all;

  @override
  List<F0223KochCurveVariant> get variants => F0223KochCurveVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
