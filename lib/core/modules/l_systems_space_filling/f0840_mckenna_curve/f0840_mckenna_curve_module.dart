// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0840_mckenna_curve_presets.dart';
import 'f0840_mckenna_curve_variants.dart';
import 'f0840_mckenna_curve_metadata.dart';

/// McKenna Curve — L-Systems & Space-Filling.
class F0840MckennaCurve extends LSystemModule {
  F0840MckennaCurve()
      : super(
          id: 'f0840_mckenna_curve',
          shader: 'shaders/f0840_mckenna_curve_gpu.frag',
        );

  @override
  F0840MckennaCurveMetadata get metadata => F0840MckennaCurveMetadata.instance;

  @override
  List<F0840MckennaCurvePreset> get presets => F0840MckennaCurvePresets.all;

  @override
  List<F0840MckennaCurveVariant> get variants => F0840MckennaCurveVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
