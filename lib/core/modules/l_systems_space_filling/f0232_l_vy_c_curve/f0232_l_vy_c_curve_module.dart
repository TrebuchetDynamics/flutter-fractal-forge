// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0232_l_vy_c_curve_presets.dart';
import 'f0232_l_vy_c_curve_variants.dart';
import 'f0232_l_vy_c_curve_metadata.dart';

/// Lévy C Curve — L-Systems & Space-Filling.
class F0232LVyCCurve extends LSystemModule {
  F0232LVyCCurve()
      : super(
          id: 'f0232_l_vy_c_curve',
          shader: 'shaders/f0232_l_vy_c_curve_gpu.frag',
        );

  @override
  F0232LVyCCurveMetadata get metadata => F0232LVyCCurveMetadata.instance;

  @override
  List<F0232LVyCCurvePreset> get presets => F0232LVyCCurvePresets.all;

  @override
  List<F0232LVyCCurveVariant> get variants => F0232LVyCCurveVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
