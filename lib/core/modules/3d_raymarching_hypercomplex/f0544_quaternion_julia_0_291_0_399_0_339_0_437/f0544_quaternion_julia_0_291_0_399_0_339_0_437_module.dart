// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0544_quaternion_julia_0_291_0_399_0_339_0_437_presets.dart';
import 'f0544_quaternion_julia_0_291_0_399_0_339_0_437_variants.dart';
import 'f0544_quaternion_julia_0_291_0_399_0_339_0_437_metadata.dart';

/// Quaternion Julia (−0.291, −0.399, 0.339, 0.437) — 3D Raymarching & Hypercomplex.
class F0544QuaternionJulia0291039903390437 extends Raymarched3DModule {
  F0544QuaternionJulia0291039903390437()
      : super(
          id: 'f0544_quaternion_julia_0_291_0_399_0_339_0_437',
          shader: 'shaders/f0544_quaternion_julia_0_291_0_399_0_339_0_437_gpu.frag',
        );

  @override
  F0544QuaternionJulia0291039903390437Metadata get metadata => F0544QuaternionJulia0291039903390437Metadata.instance;

  @override
  List<F0544QuaternionJulia0291039903390437Preset> get presets => F0544QuaternionJulia0291039903390437Presets.all;

  @override
  List<F0544QuaternionJulia0291039903390437Variant> get variants => F0544QuaternionJulia0291039903390437Variants.all;

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
