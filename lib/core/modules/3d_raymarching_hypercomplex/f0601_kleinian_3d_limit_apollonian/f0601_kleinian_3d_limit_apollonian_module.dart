// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0601_kleinian_3d_limit_apollonian_presets.dart';
import 'f0601_kleinian_3d_limit_apollonian_variants.dart';
import 'f0601_kleinian_3d_limit_apollonian_metadata.dart';

/// Kleinian 3D Limit (Apollonian) — 3D Raymarching & Hypercomplex.
class F0601Kleinian3dLimitApollonian extends Raymarched3DModule {
  F0601Kleinian3dLimitApollonian()
      : super(
          id: 'f0601_kleinian_3d_limit_apollonian',
          shader: 'shaders/f0601_kleinian_3d_limit_apollonian_gpu.frag',
        );

  @override
  F0601Kleinian3dLimitApollonianMetadata get metadata => F0601Kleinian3dLimitApollonianMetadata.instance;

  @override
  List<F0601Kleinian3dLimitApollonianPreset> get presets => F0601Kleinian3dLimitApollonianPresets.all;

  @override
  List<F0601Kleinian3dLimitApollonianVariant> get variants => F0601Kleinian3dLimitApollonianVariants.all;

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
