// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0879_zetetic_curve_presets.dart';
import 'f0879_zetetic_curve_variants.dart';
import 'f0879_zetetic_curve_metadata.dart';

/// Zetetic Curve — L-Systems & Space-Filling.
class F0879ZeteticCurve extends LSystemModule {
  F0879ZeteticCurve()
      : super(
          id: 'f0879_zetetic_curve',
          shader: 'shaders/f0879_zetetic_curve_gpu.frag',
        );

  @override
  F0879ZeteticCurveMetadata get metadata => F0879ZeteticCurveMetadata.instance;

  @override
  List<F0879ZeteticCurvePreset> get presets => F0879ZeteticCurvePresets.all;

  @override
  List<F0879ZeteticCurveVariant> get variants => F0879ZeteticCurveVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
