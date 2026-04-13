// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0594_menger_sponge_3d_presets.dart';
import 'f0594_menger_sponge_3d_variants.dart';
import 'f0594_menger_sponge_3d_metadata.dart';

/// Menger Sponge 3D — 3D Raymarching & Hypercomplex.
class F0594MengerSponge3d extends Raymarched3DModule {
  F0594MengerSponge3d()
      : super(
          id: 'f0594_menger_sponge_3d',
          shader: 'shaders/f0594_menger_sponge_3d_gpu.frag',
        );

  @override
  F0594MengerSponge3dMetadata get metadata => F0594MengerSponge3dMetadata.instance;

  @override
  List<F0594MengerSponge3dPreset> get presets => F0594MengerSponge3dPresets.all;

  @override
  List<F0594MengerSponge3dVariant> get variants => F0594MengerSponge3dVariants.all;

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
