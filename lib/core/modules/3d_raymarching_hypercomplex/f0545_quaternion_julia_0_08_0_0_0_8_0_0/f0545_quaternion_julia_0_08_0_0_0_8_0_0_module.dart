// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0545_quaternion_julia_0_08_0_0_0_8_0_0_presets.dart';
import 'f0545_quaternion_julia_0_08_0_0_0_8_0_0_variants.dart';
import 'f0545_quaternion_julia_0_08_0_0_0_8_0_0_metadata.dart';

/// Quaternion Julia (−0.08, 0.0, −0.8, 0.0) — 3D Raymarching & Hypercomplex.
class F0545QuaternionJulia008000800 extends Raymarched3DModule {
  F0545QuaternionJulia008000800()
      : super(
          id: 'f0545_quaternion_julia_0_08_0_0_0_8_0_0',
          shader: 'shaders/f0545_quaternion_julia_0_08_0_0_0_8_0_0_gpu.frag',
        );

  @override
  F0545QuaternionJulia008000800Metadata get metadata => F0545QuaternionJulia008000800Metadata.instance;

  @override
  List<F0545QuaternionJulia008000800Preset> get presets => F0545QuaternionJulia008000800Presets.all;

  @override
  List<F0545QuaternionJulia008000800Variant> get variants => F0545QuaternionJulia008000800Variants.all;

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
