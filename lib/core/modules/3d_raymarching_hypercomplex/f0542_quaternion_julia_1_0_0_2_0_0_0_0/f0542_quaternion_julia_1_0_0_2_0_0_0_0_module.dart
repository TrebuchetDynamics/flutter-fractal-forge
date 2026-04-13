// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0542_quaternion_julia_1_0_0_2_0_0_0_0_presets.dart';
import 'f0542_quaternion_julia_1_0_0_2_0_0_0_0_variants.dart';
import 'f0542_quaternion_julia_1_0_0_2_0_0_0_0_metadata.dart';

/// Quaternion Julia (−1.0, 0.2, 0.0, 0.0) — 3D Raymarching & Hypercomplex.
class F0542QuaternionJulia10020000 extends Raymarched3DModule {
  F0542QuaternionJulia10020000()
      : super(
          id: 'f0542_quaternion_julia_1_0_0_2_0_0_0_0',
          shader: 'shaders/f0542_quaternion_julia_1_0_0_2_0_0_0_0_gpu.frag',
        );

  @override
  F0542QuaternionJulia10020000Metadata get metadata => F0542QuaternionJulia10020000Metadata.instance;

  @override
  List<F0542QuaternionJulia10020000Preset> get presets => F0542QuaternionJulia10020000Presets.all;

  @override
  List<F0542QuaternionJulia10020000Variant> get variants => F0542QuaternionJulia10020000Variants.all;

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
