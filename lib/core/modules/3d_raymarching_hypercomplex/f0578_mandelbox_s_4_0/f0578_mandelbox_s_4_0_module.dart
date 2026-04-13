// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0578_mandelbox_s_4_0_presets.dart';
import 'f0578_mandelbox_s_4_0_variants.dart';
import 'f0578_mandelbox_s_4_0_metadata.dart';

/// Mandelbox s=4.0 — 3D Raymarching & Hypercomplex.
class F0578MandelboxS40 extends Raymarched3DModule {
  F0578MandelboxS40()
      : super(
          id: 'f0578_mandelbox_s_4_0',
          shader: 'shaders/f0578_mandelbox_s_4_0_gpu.frag',
        );

  @override
  F0578MandelboxS40Metadata get metadata => F0578MandelboxS40Metadata.instance;

  @override
  List<F0578MandelboxS40Preset> get presets => F0578MandelboxS40Presets.all;

  @override
  List<F0578MandelboxS40Variant> get variants => F0578MandelboxS40Variants.all;

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
