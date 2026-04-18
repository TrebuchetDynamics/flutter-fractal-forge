// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0693_wang_tile_set_kari_culik_13_tile_presets.dart';
import 'f0693_wang_tile_set_kari_culik_13_tile_variants.dart';
import 'f0693_wang_tile_set_kari_culik_13_tile_metadata.dart';

/// Wang Tile Set (Kari-Culik 13-tile) — Tiling & Aperiodic.
class F0693WangTileSetKariCulik13Tile extends IFSModule {
  F0693WangTileSetKariCulik13Tile()
      : super(
          id: 'f0693_wang_tile_set_kari_culik_13_tile',
          shader: 'shaders/f0693_wang_tile_set_kari_culik_13_tile_gpu.frag',
        );

  @override
  F0693WangTileSetKariCulik13TileMetadata get metadata => F0693WangTileSetKariCulik13TileMetadata.instance;

  @override
  List<F0693WangTileSetKariCulik13TilePreset> get presets => F0693WangTileSetKariCulik13TilePresets.all;

  @override
  List<F0693WangTileSetKariCulik13TileVariant> get variants => F0693WangTileSetKariCulik13TileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
