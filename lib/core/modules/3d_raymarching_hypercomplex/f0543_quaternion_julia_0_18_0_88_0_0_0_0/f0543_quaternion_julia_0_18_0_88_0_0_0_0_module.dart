// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'metadata/f0543_quaternion_julia_0_18_0_88_0_0_0_0_metadata.dart';
import 'presets/f0543_quaternion_julia_0_18_0_88_0_0_0_0_presets.dart';
import 'variants/f0543_quaternion_julia_0_18_0_88_0_0_0_0_variants.dart';

/// Quaternion Julia (0.18, 0.88, 0.0, 0.0) — 3D Raymarching & Hypercomplex.
class F0543QuaternionJulia0180880000 extends Raymarched3DModule {
  F0543QuaternionJulia0180880000()
      : super(
          id: 'f0543_quaternion_julia_0_18_0_88_0_0_0_0',
          shader: 'shaders/f0543_quaternion_julia_0_18_0_88_0_0_0_0_gpu.frag',
        );

  @override
  F0543QuaternionJulia0180880000Metadata get metadata => F0543QuaternionJulia0180880000Metadata.instance;

  @override
  List<F0543QuaternionJulia0180880000Preset> get presets => F0543QuaternionJulia0180880000Presets.all;

  @override
  List<F0543QuaternionJulia0180880000Variant> get variants => F0543QuaternionJulia0180880000Variants.all;

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
