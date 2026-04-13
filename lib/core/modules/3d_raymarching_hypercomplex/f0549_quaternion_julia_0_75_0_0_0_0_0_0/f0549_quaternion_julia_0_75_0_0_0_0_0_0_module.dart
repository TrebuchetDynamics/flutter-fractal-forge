// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0549_quaternion_julia_0_75_0_0_0_0_0_0_presets.dart';
import 'f0549_quaternion_julia_0_75_0_0_0_0_0_0_variants.dart';
import 'f0549_quaternion_julia_0_75_0_0_0_0_0_0_metadata.dart';

/// Quaternion Julia (−0.75, 0.0, 0.0, 0.0) — 3D Raymarching & Hypercomplex.
class F0549QuaternionJulia075000000 extends Raymarched3DModule {
  F0549QuaternionJulia075000000()
      : super(
          id: 'f0549_quaternion_julia_0_75_0_0_0_0_0_0',
          shader: 'shaders/f0549_quaternion_julia_0_75_0_0_0_0_0_0_gpu.frag',
        );

  @override
  F0549QuaternionJulia075000000Metadata get metadata => F0549QuaternionJulia075000000Metadata.instance;

  @override
  List<F0549QuaternionJulia075000000Preset> get presets => F0549QuaternionJulia075000000Presets.all;

  @override
  List<F0549QuaternionJulia075000000Variant> get variants => F0549QuaternionJulia075000000Variants.all;

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
