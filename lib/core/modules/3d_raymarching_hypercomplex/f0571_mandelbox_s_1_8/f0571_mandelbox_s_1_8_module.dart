// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0571_mandelbox_s_1_8_presets.dart';
import 'f0571_mandelbox_s_1_8_variants.dart';
import 'f0571_mandelbox_s_1_8_metadata.dart';

/// Mandelbox s=1.8 — 3D Raymarching & Hypercomplex.
class F0571MandelboxS18 extends Raymarched3DModule {
  F0571MandelboxS18()
      : super(
          id: 'f0571_mandelbox_s_1_8',
          shader: 'shaders/f0571_mandelbox_s_1_8_gpu.frag',
        );

  @override
  F0571MandelboxS18Metadata get metadata => F0571MandelboxS18Metadata.instance;

  @override
  List<F0571MandelboxS18Preset> get presets => F0571MandelboxS18Presets.all;

  @override
  List<F0571MandelboxS18Variant> get variants => F0571MandelboxS18Variants.all;

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
