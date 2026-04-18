// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0841_lebesgue_curve_presets.dart';
import 'f0841_lebesgue_curve_variants.dart';
import 'f0841_lebesgue_curve_metadata.dart';

/// Lebesgue Curve — L-Systems & Space-Filling.
class F0841LebesgueCurve extends LSystemModule {
  F0841LebesgueCurve()
      : super(
          id: 'f0841_lebesgue_curve',
          shader: 'shaders/f0841_lebesgue_curve_gpu.frag',
        );

  @override
  F0841LebesgueCurveMetadata get metadata => F0841LebesgueCurveMetadata.instance;

  @override
  List<F0841LebesgueCurvePreset> get presets => F0841LebesgueCurvePresets.all;

  @override
  List<F0841LebesgueCurveVariant> get variants => F0841LebesgueCurveVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
