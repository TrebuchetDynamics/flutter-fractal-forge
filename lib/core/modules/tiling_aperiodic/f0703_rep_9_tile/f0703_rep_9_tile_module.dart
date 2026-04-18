// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0703_rep_9_tile_presets.dart';
import 'f0703_rep_9_tile_variants.dart';
import 'f0703_rep_9_tile_metadata.dart';

/// Rep-9 Tile — Tiling & Aperiodic.
class F0703Rep9Tile extends IFSModule {
  F0703Rep9Tile()
      : super(
          id: 'f0703_rep_9_tile',
          shader: 'shaders/f0703_rep_9_tile_gpu.frag',
        );

  @override
  F0703Rep9TileMetadata get metadata => F0703Rep9TileMetadata.instance;

  @override
  List<F0703Rep9TilePreset> get presets => F0703Rep9TilePresets.all;

  @override
  List<F0703Rep9TileVariant> get variants => F0703Rep9TileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
