// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0699_lebesgue_tile_presets.dart';
import 'f0699_lebesgue_tile_variants.dart';
import 'f0699_lebesgue_tile_metadata.dart';

/// Lebesgue Tile — Tiling & Aperiodic.
class F0699LebesgueTile extends IFSModule {
  F0699LebesgueTile()
      : super(
          id: 'f0699_lebesgue_tile',
          shader: 'shaders/f0699_lebesgue_tile_gpu.frag',
        );

  @override
  F0699LebesgueTileMetadata get metadata => F0699LebesgueTileMetadata.instance;

  @override
  List<F0699LebesgueTilePreset> get presets => F0699LebesgueTilePresets.all;

  @override
  List<F0699LebesgueTileVariant> get variants => F0699LebesgueTileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
