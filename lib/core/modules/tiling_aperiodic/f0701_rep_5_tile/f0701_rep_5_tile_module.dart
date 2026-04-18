// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0701_rep_5_tile_presets.dart';
import 'f0701_rep_5_tile_variants.dart';
import 'f0701_rep_5_tile_metadata.dart';

/// Rep-5 Tile — Tiling & Aperiodic.
class F0701Rep5Tile extends IFSModule {
  F0701Rep5Tile()
      : super(
          id: 'f0701_rep_5_tile',
          shader: 'shaders/f0701_rep_5_tile_gpu.frag',
        );

  @override
  F0701Rep5TileMetadata get metadata => F0701Rep5TileMetadata.instance;

  @override
  List<F0701Rep5TilePreset> get presets => F0701Rep5TilePresets.all;

  @override
  List<F0701Rep5TileVariant> get variants => F0701Rep5TileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
