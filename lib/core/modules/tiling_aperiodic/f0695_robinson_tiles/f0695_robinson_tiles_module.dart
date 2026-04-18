// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0695_robinson_tiles_presets.dart';
import 'f0695_robinson_tiles_variants.dart';
import 'f0695_robinson_tiles_metadata.dart';

/// Robinson Tiles — Tiling & Aperiodic.
class F0695RobinsonTiles extends IFSModule {
  F0695RobinsonTiles()
      : super(
          id: 'f0695_robinson_tiles',
          shader: 'shaders/f0695_robinson_tiles_gpu.frag',
        );

  @override
  F0695RobinsonTilesMetadata get metadata => F0695RobinsonTilesMetadata.instance;

  @override
  List<F0695RobinsonTilesPreset> get presets => F0695RobinsonTilesPresets.all;

  @override
  List<F0695RobinsonTilesVariant> get variants => F0695RobinsonTilesVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
