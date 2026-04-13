// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0581_mandelbox_s_2_5_presets.dart';
import 'f0581_mandelbox_s_2_5_variants.dart';
import 'f0581_mandelbox_s_2_5_metadata.dart';

/// Mandelbox s=-2.5 — 3D Raymarching & Hypercomplex.
class F0581MandelboxS25 extends Raymarched3DModule {
  F0581MandelboxS25()
      : super(
          id: 'f0581_mandelbox_s_2_5',
          shader: 'shaders/f0581_mandelbox_s_2_5_gpu.frag',
        );

  @override
  F0581MandelboxS25Metadata get metadata => F0581MandelboxS25Metadata.instance;

  @override
  List<F0581MandelboxS25Preset> get presets => F0581MandelboxS25Presets.all;

  @override
  List<F0581MandelboxS25Variant> get variants => F0581MandelboxS25Variants.all;

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
