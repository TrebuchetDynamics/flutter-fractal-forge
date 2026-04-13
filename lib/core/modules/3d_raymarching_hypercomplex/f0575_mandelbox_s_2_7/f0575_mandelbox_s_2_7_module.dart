// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0575_mandelbox_s_2_7_presets.dart';
import 'f0575_mandelbox_s_2_7_variants.dart';
import 'f0575_mandelbox_s_2_7_metadata.dart';

/// Mandelbox s=2.7 — 3D Raymarching & Hypercomplex.
class F0575MandelboxS27 extends Raymarched3DModule {
  F0575MandelboxS27()
      : super(
          id: 'f0575_mandelbox_s_2_7',
          shader: 'shaders/f0575_mandelbox_s_2_7_gpu.frag',
        );

  @override
  F0575MandelboxS27Metadata get metadata => F0575MandelboxS27Metadata.instance;

  @override
  List<F0575MandelboxS27Preset> get presets => F0575MandelboxS27Presets.all;

  @override
  List<F0575MandelboxS27Variant> get variants => F0575MandelboxS27Variants.all;

  @override
  double get defaultPower => 8.0;

  @override
  int get defaultSteps => 200;

  @override
  int get defaultIterations => 20;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setInt('steps', defaultSteps);
    p.setInt('iterations', defaultIterations);
  }
}
