// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0547_quaternion_julia_0_54_0_60_0_18_0_27_presets.dart';
import 'f0547_quaternion_julia_0_54_0_60_0_18_0_27_variants.dart';
import 'f0547_quaternion_julia_0_54_0_60_0_18_0_27_metadata.dart';

/// Quaternion Julia (−0.54, 0.60, 0.18, 0.27) — 3D Raymarching & Hypercomplex.
class F0547QuaternionJulia054060018027 extends Raymarched3DModule {
  F0547QuaternionJulia054060018027()
      : super(
          id: 'f0547_quaternion_julia_0_54_0_60_0_18_0_27',
          shader: 'shaders/f0547_quaternion_julia_0_54_0_60_0_18_0_27_gpu.frag',
        );

  @override
  F0547QuaternionJulia054060018027Metadata get metadata => F0547QuaternionJulia054060018027Metadata.instance;

  @override
  List<F0547QuaternionJulia054060018027Preset> get presets => F0547QuaternionJulia054060018027Presets.all;

  @override
  List<F0547QuaternionJulia054060018027Variant> get variants => F0547QuaternionJulia054060018027Variants.all;

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
