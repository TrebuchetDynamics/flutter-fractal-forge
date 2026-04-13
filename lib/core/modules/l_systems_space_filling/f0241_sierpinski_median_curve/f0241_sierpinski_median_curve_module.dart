// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0241_sierpinski_median_curve_presets.dart';
import 'f0241_sierpinski_median_curve_variants.dart';
import 'f0241_sierpinski_median_curve_metadata.dart';

/// Sierpinski Median Curve — L-Systems & Space-Filling.
class F0241SierpinskiMedianCurve extends LSystemModule {
  F0241SierpinskiMedianCurve()
      : super(
          id: 'f0241_sierpinski_median_curve',
          shader: 'shaders/f0241_sierpinski_median_curve_gpu.frag',
        );

  @override
  F0241SierpinskiMedianCurveMetadata get metadata => F0241SierpinskiMedianCurveMetadata.instance;

  @override
  List<F0241SierpinskiMedianCurvePreset> get presets => F0241SierpinskiMedianCurvePresets.all;

  @override
  List<F0241SierpinskiMedianCurveVariant> get variants => F0241SierpinskiMedianCurveVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
