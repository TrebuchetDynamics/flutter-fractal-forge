// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0877_prouhet_thue_morse_curve_l_system_presets.dart';
import 'f0877_prouhet_thue_morse_curve_l_system_variants.dart';
import 'f0877_prouhet_thue_morse_curve_l_system_metadata.dart';

/// Prouhet-Thue-Morse Curve L-system — L-Systems & Space-Filling.
class F0877ProuhetThueMorseCurveLSystem extends LSystemModule {
  F0877ProuhetThueMorseCurveLSystem()
      : super(
          id: 'f0877_prouhet_thue_morse_curve_l_system',
          shader: 'shaders/f0877_prouhet_thue_morse_curve_l_system_gpu.frag',
        );

  @override
  F0877ProuhetThueMorseCurveLSystemMetadata get metadata => F0877ProuhetThueMorseCurveLSystemMetadata.instance;

  @override
  List<F0877ProuhetThueMorseCurveLSystemPreset> get presets => F0877ProuhetThueMorseCurveLSystemPresets.all;

  @override
  List<F0877ProuhetThueMorseCurveLSystemVariant> get variants => F0877ProuhetThueMorseCurveLSystemVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
