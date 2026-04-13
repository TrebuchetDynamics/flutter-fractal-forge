// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0275_menger_sponge_2d_carpet_presets.dart';
import 'f0275_menger_sponge_2d_carpet_variants.dart';
import 'f0275_menger_sponge_2d_carpet_metadata.dart';

/// Menger Sponge 2D (Carpet+) — IFS & Geometric Construction.
class F0275MengerSponge2dCarpet extends IFSModule {
  F0275MengerSponge2dCarpet()
      : super(
          id: 'f0275_menger_sponge_2d_carpet',
          shader: 'shaders/f0275_menger_sponge_2d_carpet_gpu.frag',
        );

  @override
  F0275MengerSponge2dCarpetMetadata get metadata => F0275MengerSponge2dCarpetMetadata.instance;

  @override
  List<F0275MengerSponge2dCarpetPreset> get presets => F0275MengerSponge2dCarpetPresets.all;

  @override
  List<F0275MengerSponge2dCarpetVariant> get variants => F0275MengerSponge2dCarpetVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
