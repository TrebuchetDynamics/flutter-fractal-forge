// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0686_ammann_beenker_tiling_presets.dart';
import 'f0686_ammann_beenker_tiling_variants.dart';
import 'f0686_ammann_beenker_tiling_metadata.dart';

/// Ammann-Beenker Tiling — Tiling & Aperiodic.
class F0686AmmannBeenkerTiling extends IFSModule {
  F0686AmmannBeenkerTiling()
      : super(
          id: 'f0686_ammann_beenker_tiling',
          shader: 'shaders/f0686_ammann_beenker_tiling_gpu.frag',
        );

  @override
  F0686AmmannBeenkerTilingMetadata get metadata => F0686AmmannBeenkerTilingMetadata.instance;

  @override
  List<F0686AmmannBeenkerTilingPreset> get presets => F0686AmmannBeenkerTilingPresets.all;

  @override
  List<F0686AmmannBeenkerTilingVariant> get variants => F0686AmmannBeenkerTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
