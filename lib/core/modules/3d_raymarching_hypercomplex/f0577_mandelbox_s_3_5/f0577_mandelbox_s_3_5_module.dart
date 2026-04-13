// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0577_mandelbox_s_3_5_presets.dart';
import 'f0577_mandelbox_s_3_5_variants.dart';
import 'f0577_mandelbox_s_3_5_metadata.dart';

/// Mandelbox s=3.5 — 3D Raymarching & Hypercomplex.
class F0577MandelboxS35 extends Raymarched3DModule {
  F0577MandelboxS35()
      : super(
          id: 'f0577_mandelbox_s_3_5',
          shader: 'shaders/f0577_mandelbox_s_3_5_gpu.frag',
        );

  @override
  F0577MandelboxS35Metadata get metadata => F0577MandelboxS35Metadata.instance;

  @override
  List<F0577MandelboxS35Preset> get presets => F0577MandelboxS35Presets.all;

  @override
  List<F0577MandelboxS35Variant> get variants => F0577MandelboxS35Variants.all;

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
