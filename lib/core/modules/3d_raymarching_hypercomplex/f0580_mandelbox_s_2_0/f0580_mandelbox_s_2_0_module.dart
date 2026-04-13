// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0580_mandelbox_s_2_0_presets.dart';
import 'f0580_mandelbox_s_2_0_variants.dart';
import 'f0580_mandelbox_s_2_0_metadata.dart';

/// Mandelbox s=-2.0 — 3D Raymarching & Hypercomplex.
class F0580MandelboxS20 extends Raymarched3DModule {
  F0580MandelboxS20()
      : super(
          id: 'f0580_mandelbox_s_2_0',
          shader: 'shaders/f0580_mandelbox_s_2_0_gpu.frag',
        );

  @override
  F0580MandelboxS20Metadata get metadata => F0580MandelboxS20Metadata.instance;

  @override
  List<F0580MandelboxS20Preset> get presets => F0580MandelboxS20Presets.all;

  @override
  List<F0580MandelboxS20Variant> get variants => F0580MandelboxS20Variants.all;

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
