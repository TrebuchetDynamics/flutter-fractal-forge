// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0276_menger_sponge_3d_presets.dart';
import 'f0276_menger_sponge_3d_variants.dart';
import 'f0276_menger_sponge_3d_metadata.dart';

/// Menger Sponge 3D — IFS & Geometric Construction.
class F0276MengerSponge3d extends IFSModule {
  F0276MengerSponge3d()
      : super(
          id: 'f0276_menger_sponge_3d',
          shader: 'shaders/f0276_menger_sponge_3d_gpu.frag',
        );

  @override
  F0276MengerSponge3dMetadata get metadata => F0276MengerSponge3dMetadata.instance;

  @override
  List<F0276MengerSponge3dPreset> get presets => F0276MengerSponge3dPresets.all;

  @override
  List<F0276MengerSponge3dVariant> get variants => F0276MengerSponge3dVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
