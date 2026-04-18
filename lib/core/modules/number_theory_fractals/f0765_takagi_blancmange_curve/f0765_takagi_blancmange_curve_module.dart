// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0765_takagi_blancmange_curve_presets.dart';
import 'f0765_takagi_blancmange_curve_variants.dart';
import 'f0765_takagi_blancmange_curve_metadata.dart';

/// Takagi (Blancmange) Curve — Number-Theory Fractals.
class F0765TakagiBlancmangeCurve extends CellularModule {
  F0765TakagiBlancmangeCurve()
      : super(
          id: 'f0765_takagi_blancmange_curve',
          shader: 'shaders/f0765_takagi_blancmange_curve_gpu.frag',
        );

  @override
  F0765TakagiBlancmangeCurveMetadata get metadata => F0765TakagiBlancmangeCurveMetadata.instance;

  @override
  List<F0765TakagiBlancmangeCurvePreset> get presets => F0765TakagiBlancmangeCurvePresets.all;

  @override
  List<F0765TakagiBlancmangeCurveVariant> get variants => F0765TakagiBlancmangeCurveVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
