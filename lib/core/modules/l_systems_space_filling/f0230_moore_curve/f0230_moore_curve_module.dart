// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0230_moore_curve_presets.dart';
import 'f0230_moore_curve_variants.dart';
import 'f0230_moore_curve_metadata.dart';

/// Moore Curve — L-Systems & Space-Filling.
class F0230MooreCurve extends LSystemModule {
  F0230MooreCurve()
      : super(
          id: 'f0230_moore_curve',
          shader: 'shaders/f0230_moore_curve_gpu.frag',
        );

  @override
  F0230MooreCurveMetadata get metadata => F0230MooreCurveMetadata.instance;

  @override
  List<F0230MooreCurvePreset> get presets => F0230MooreCurvePresets.all;

  @override
  List<F0230MooreCurveVariant> get variants => F0230MooreCurveVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
