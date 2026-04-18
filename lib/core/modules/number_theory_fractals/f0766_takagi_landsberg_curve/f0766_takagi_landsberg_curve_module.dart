// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0766_takagi_landsberg_curve_presets.dart';
import 'f0766_takagi_landsberg_curve_variants.dart';
import 'f0766_takagi_landsberg_curve_metadata.dart';

/// Takagi-Landsberg Curve — Number-Theory Fractals.
class F0766TakagiLandsbergCurve extends CellularModule {
  F0766TakagiLandsbergCurve()
      : super(
          id: 'f0766_takagi_landsberg_curve',
          shader: 'shaders/f0766_takagi_landsberg_curve_gpu.frag',
        );

  @override
  F0766TakagiLandsbergCurveMetadata get metadata => F0766TakagiLandsbergCurveMetadata.instance;

  @override
  List<F0766TakagiLandsbergCurvePreset> get presets => F0766TakagiLandsbergCurvePresets.all;

  @override
  List<F0766TakagiLandsbergCurveVariant> get variants => F0766TakagiLandsbergCurveVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
