// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0548_quaternion_julia_0_0_0_7_0_0_0_0_presets.dart';
import 'f0548_quaternion_julia_0_0_0_7_0_0_0_0_variants.dart';
import 'f0548_quaternion_julia_0_0_0_7_0_0_0_0_metadata.dart';

/// Quaternion Julia (0.0, 0.7, 0.0, 0.0) — 3D Raymarching & Hypercomplex.
class F0548QuaternionJulia00070000 extends Raymarched3DModule {
  F0548QuaternionJulia00070000()
      : super(
          id: 'f0548_quaternion_julia_0_0_0_7_0_0_0_0',
          shader: 'shaders/f0548_quaternion_julia_0_0_0_7_0_0_0_0_gpu.frag',
        );

  @override
  F0548QuaternionJulia00070000Metadata get metadata => F0548QuaternionJulia00070000Metadata.instance;

  @override
  List<F0548QuaternionJulia00070000Preset> get presets => F0548QuaternionJulia00070000Presets.all;

  @override
  List<F0548QuaternionJulia00070000Variant> get variants => F0548QuaternionJulia00070000Variants.all;

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
