// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0878_williams_beasley_curve_presets.dart';
import 'f0878_williams_beasley_curve_variants.dart';
import 'f0878_williams_beasley_curve_metadata.dart';

/// Williams-Beasley Curve — L-Systems & Space-Filling.
class F0878WilliamsBeasleyCurve extends LSystemModule {
  F0878WilliamsBeasleyCurve()
      : super(
          id: 'f0878_williams_beasley_curve',
          shader: 'shaders/f0878_williams_beasley_curve_gpu.frag',
        );

  @override
  F0878WilliamsBeasleyCurveMetadata get metadata => F0878WilliamsBeasleyCurveMetadata.instance;

  @override
  List<F0878WilliamsBeasleyCurvePreset> get presets => F0878WilliamsBeasleyCurvePresets.all;

  @override
  List<F0878WilliamsBeasleyCurveVariant> get variants => F0878WilliamsBeasleyCurveVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
