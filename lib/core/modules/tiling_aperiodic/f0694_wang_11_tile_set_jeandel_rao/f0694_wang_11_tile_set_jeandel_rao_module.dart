// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0694_wang_11_tile_set_jeandel_rao_presets.dart';
import 'f0694_wang_11_tile_set_jeandel_rao_variants.dart';
import 'f0694_wang_11_tile_set_jeandel_rao_metadata.dart';

/// Wang 11-Tile Set (Jeandel-Rao) — Tiling & Aperiodic.
class F0694Wang11TileSetJeandelRao extends IFSModule {
  F0694Wang11TileSetJeandelRao()
      : super(
          id: 'f0694_wang_11_tile_set_jeandel_rao',
          shader: 'shaders/f0694_wang_11_tile_set_jeandel_rao_gpu.frag',
        );

  @override
  F0694Wang11TileSetJeandelRaoMetadata get metadata => F0694Wang11TileSetJeandelRaoMetadata.instance;

  @override
  List<F0694Wang11TileSetJeandelRaoPreset> get presets => F0694Wang11TileSetJeandelRaoPresets.all;

  @override
  List<F0694Wang11TileSetJeandelRaoVariant> get variants => F0694Wang11TileSetJeandelRaoVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
