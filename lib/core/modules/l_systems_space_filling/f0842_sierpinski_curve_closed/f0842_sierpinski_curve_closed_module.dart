// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0842_sierpinski_curve_closed_presets.dart';
import 'f0842_sierpinski_curve_closed_variants.dart';
import 'f0842_sierpinski_curve_closed_metadata.dart';

/// Sierpinski Curve (Closed) — L-Systems & Space-Filling.
class F0842SierpinskiCurveClosed extends LSystemModule {
  F0842SierpinskiCurveClosed()
      : super(
          id: 'f0842_sierpinski_curve_closed',
          shader: 'shaders/f0842_sierpinski_curve_closed_gpu.frag',
        );

  @override
  F0842SierpinskiCurveClosedMetadata get metadata => F0842SierpinskiCurveClosedMetadata.instance;

  @override
  List<F0842SierpinskiCurveClosedPreset> get presets => F0842SierpinskiCurveClosedPresets.all;

  @override
  List<F0842SierpinskiCurveClosedVariant> get variants => F0842SierpinskiCurveClosedVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
