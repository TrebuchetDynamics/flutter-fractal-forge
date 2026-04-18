// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0778_prouhet_thue_morse_curve_presets.dart';
import 'f0778_prouhet_thue_morse_curve_variants.dart';
import 'f0778_prouhet_thue_morse_curve_metadata.dart';

/// Prouhet-Thue-Morse Curve — Number-Theory Fractals.
class F0778ProuhetThueMorseCurve extends CellularModule {
  F0778ProuhetThueMorseCurve()
      : super(
          id: 'f0778_prouhet_thue_morse_curve',
          shader: 'shaders/f0778_prouhet_thue_morse_curve_gpu.frag',
        );

  @override
  F0778ProuhetThueMorseCurveMetadata get metadata => F0778ProuhetThueMorseCurveMetadata.instance;

  @override
  List<F0778ProuhetThueMorseCurvePreset> get presets => F0778ProuhetThueMorseCurvePresets.all;

  @override
  List<F0778ProuhetThueMorseCurveVariant> get variants => F0778ProuhetThueMorseCurveVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
