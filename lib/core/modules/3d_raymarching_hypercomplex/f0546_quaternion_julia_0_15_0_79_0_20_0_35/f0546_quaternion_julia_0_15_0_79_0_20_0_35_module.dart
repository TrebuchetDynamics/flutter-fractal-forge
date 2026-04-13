// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0546_quaternion_julia_0_15_0_79_0_20_0_35_presets.dart';
import 'f0546_quaternion_julia_0_15_0_79_0_20_0_35_variants.dart';
import 'f0546_quaternion_julia_0_15_0_79_0_20_0_35_metadata.dart';

/// Quaternion Julia (0.15, 0.79, 0.20, 0.35) — 3D Raymarching & Hypercomplex.
class F0546QuaternionJulia015079020035 extends Raymarched3DModule {
  F0546QuaternionJulia015079020035()
      : super(
          id: 'f0546_quaternion_julia_0_15_0_79_0_20_0_35',
          shader: 'shaders/f0546_quaternion_julia_0_15_0_79_0_20_0_35_gpu.frag',
        );

  @override
  F0546QuaternionJulia015079020035Metadata get metadata => F0546QuaternionJulia015079020035Metadata.instance;

  @override
  List<F0546QuaternionJulia015079020035Preset> get presets => F0546QuaternionJulia015079020035Presets.all;

  @override
  List<F0546QuaternionJulia015079020035Variant> get variants => F0546QuaternionJulia015079020035Variants.all;

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
