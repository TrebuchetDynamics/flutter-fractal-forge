// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0702_rep_7_tile_presets.dart';
import 'f0702_rep_7_tile_variants.dart';
import 'f0702_rep_7_tile_metadata.dart';

/// Rep-7 Tile — Tiling & Aperiodic.
class F0702Rep7Tile extends IFSModule {
  F0702Rep7Tile()
      : super(
          id: 'f0702_rep_7_tile',
          shader: 'shaders/f0702_rep_7_tile_gpu.frag',
        );

  @override
  F0702Rep7TileMetadata get metadata => F0702Rep7TileMetadata.instance;

  @override
  List<F0702Rep7TilePreset> get presets => F0702Rep7TilePresets.all;

  @override
  List<F0702Rep7TileVariant> get variants => F0702Rep7TileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
