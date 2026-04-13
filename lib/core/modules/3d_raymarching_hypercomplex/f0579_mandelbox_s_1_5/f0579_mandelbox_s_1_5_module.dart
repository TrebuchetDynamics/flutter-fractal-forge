// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0579_mandelbox_s_1_5_presets.dart';
import 'f0579_mandelbox_s_1_5_variants.dart';
import 'f0579_mandelbox_s_1_5_metadata.dart';

/// Mandelbox s=-1.5 — 3D Raymarching & Hypercomplex.
class F0579MandelboxS15 extends Raymarched3DModule {
  F0579MandelboxS15()
      : super(
          id: 'f0579_mandelbox_s_1_5',
          shader: 'shaders/f0579_mandelbox_s_1_5_gpu.frag',
        );

  @override
  F0579MandelboxS15Metadata get metadata => F0579MandelboxS15Metadata.instance;

  @override
  List<F0579MandelboxS15Preset> get presets => F0579MandelboxS15Presets.all;

  @override
  List<F0579MandelboxS15Variant> get variants => F0579MandelboxS15Variants.all;

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
