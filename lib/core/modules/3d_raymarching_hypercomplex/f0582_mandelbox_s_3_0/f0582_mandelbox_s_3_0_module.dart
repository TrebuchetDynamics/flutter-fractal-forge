// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0582_mandelbox_s_3_0_presets.dart';
import 'f0582_mandelbox_s_3_0_variants.dart';
import 'f0582_mandelbox_s_3_0_metadata.dart';

/// Mandelbox s=-3.0 — 3D Raymarching & Hypercomplex.
class F0582MandelboxS30 extends Raymarched3DModule {
  F0582MandelboxS30()
      : super(
          id: 'f0582_mandelbox_s_3_0',
          shader: 'shaders/f0582_mandelbox_s_3_0_gpu.frag',
        );

  @override
  F0582MandelboxS30Metadata get metadata => F0582MandelboxS30Metadata.instance;

  @override
  List<F0582MandelboxS30Preset> get presets => F0582MandelboxS30Presets.all;

  @override
  List<F0582MandelboxS30Variant> get variants => F0582MandelboxS30Variants.all;

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
