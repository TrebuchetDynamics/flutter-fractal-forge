// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0843_sierpinski_knopp_curve_presets.dart';
import 'f0843_sierpinski_knopp_curve_variants.dart';
import 'f0843_sierpinski_knopp_curve_metadata.dart';

/// Sierpinski-Knopp Curve — L-Systems & Space-Filling.
class F0843SierpinskiKnoppCurve extends LSystemModule {
  F0843SierpinskiKnoppCurve()
      : super(
          id: 'f0843_sierpinski_knopp_curve',
          shader: 'shaders/f0843_sierpinski_knopp_curve_gpu.frag',
        );

  @override
  F0843SierpinskiKnoppCurveMetadata get metadata => F0843SierpinskiKnoppCurveMetadata.instance;

  @override
  List<F0843SierpinskiKnoppCurvePreset> get presets => F0843SierpinskiKnoppCurvePresets.all;

  @override
  List<F0843SierpinskiKnoppCurveVariant> get variants => F0843SierpinskiKnoppCurveVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
