// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0602_kleinian_3d_indra_presets.dart';
import 'f0602_kleinian_3d_indra_variants.dart';
import 'f0602_kleinian_3d_indra_metadata.dart';

/// Kleinian 3D Indra — 3D Raymarching & Hypercomplex.
class F0602Kleinian3dIndra extends Raymarched3DModule {
  F0602Kleinian3dIndra()
      : super(
          id: 'f0602_kleinian_3d_indra',
          shader: 'shaders/f0602_kleinian_3d_indra_gpu.frag',
        );

  @override
  F0602Kleinian3dIndraMetadata get metadata => F0602Kleinian3dIndraMetadata.instance;

  @override
  List<F0602Kleinian3dIndraPreset> get presets => F0602Kleinian3dIndraPresets.all;

  @override
  List<F0602Kleinian3dIndraVariant> get variants => F0602Kleinian3dIndraVariants.all;

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
