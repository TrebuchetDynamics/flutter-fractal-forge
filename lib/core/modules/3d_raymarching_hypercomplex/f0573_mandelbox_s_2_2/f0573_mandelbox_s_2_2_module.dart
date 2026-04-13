// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0573_mandelbox_s_2_2_presets.dart';
import 'f0573_mandelbox_s_2_2_variants.dart';
import 'f0573_mandelbox_s_2_2_metadata.dart';

/// Mandelbox s=2.2 — 3D Raymarching & Hypercomplex.
class F0573MandelboxS22 extends Raymarched3DModule {
  F0573MandelboxS22()
      : super(
          id: 'f0573_mandelbox_s_2_2',
          shader: 'shaders/f0573_mandelbox_s_2_2_gpu.frag',
        );

  @override
  F0573MandelboxS22Metadata get metadata => F0573MandelboxS22Metadata.instance;

  @override
  List<F0573MandelboxS22Preset> get presets => F0573MandelboxS22Presets.all;

  @override
  List<F0573MandelboxS22Variant> get variants => F0573MandelboxS22Variants.all;

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
