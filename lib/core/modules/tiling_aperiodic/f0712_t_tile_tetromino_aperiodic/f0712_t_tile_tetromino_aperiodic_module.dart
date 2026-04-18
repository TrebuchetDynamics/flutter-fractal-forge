// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0712_t_tile_tetromino_aperiodic_presets.dart';
import 'f0712_t_tile_tetromino_aperiodic_variants.dart';
import 'f0712_t_tile_tetromino_aperiodic_metadata.dart';

/// T-Tile (Tetromino Aperiodic) — Tiling & Aperiodic.
class F0712TTileTetrominoAperiodic extends IFSModule {
  F0712TTileTetrominoAperiodic()
      : super(
          id: 'f0712_t_tile_tetromino_aperiodic',
          shader: 'shaders/f0712_t_tile_tetromino_aperiodic_gpu.frag',
        );

  @override
  F0712TTileTetrominoAperiodicMetadata get metadata => F0712TTileTetrominoAperiodicMetadata.instance;

  @override
  List<F0712TTileTetrominoAperiodicPreset> get presets => F0712TTileTetrominoAperiodicPresets.all;

  @override
  List<F0712TTileTetrominoAperiodicVariant> get variants => F0712TTileTetrominoAperiodicVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
