// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'metadata/f0541_quaternion_julia_0_125_0_256_0_847_0_089_metadata.dart';
import 'presets/f0541_quaternion_julia_0_125_0_256_0_847_0_089_presets.dart';
import 'variants/f0541_quaternion_julia_0_125_0_256_0_847_0_089_variants.dart';

/// Quaternion Julia (−0.125, −0.256, 0.847, 0.0895) — 3D Raymarching & Hypercomplex.
class F0541QuaternionJulia0125025608470089 extends Raymarched3DModule {
  F0541QuaternionJulia0125025608470089()
      : super(
          id: 'f0541_quaternion_julia_0_125_0_256_0_847_0_089',
          shader: 'shaders/f0541_quaternion_julia_0_125_0_256_0_847_0_089_gpu.frag',
        );

  @override
  F0541QuaternionJulia0125025608470089Metadata get metadata => F0541QuaternionJulia0125025608470089Metadata.instance;

  @override
  List<F0541QuaternionJulia0125025608470089Preset> get presets => F0541QuaternionJulia0125025608470089Presets.all;

  @override
  List<F0541QuaternionJulia0125025608470089Variant> get variants => F0541QuaternionJulia0125025608470089Variants.all;

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
