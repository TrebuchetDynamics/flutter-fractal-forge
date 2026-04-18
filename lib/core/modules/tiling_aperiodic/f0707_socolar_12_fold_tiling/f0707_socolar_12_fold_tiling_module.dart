// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0707_socolar_12_fold_tiling_presets.dart';
import 'f0707_socolar_12_fold_tiling_variants.dart';
import 'f0707_socolar_12_fold_tiling_metadata.dart';

/// Socolar 12-Fold Tiling — Tiling & Aperiodic.
class F0707Socolar12FoldTiling extends IFSModule {
  F0707Socolar12FoldTiling()
      : super(
          id: 'f0707_socolar_12_fold_tiling',
          shader: 'shaders/f0707_socolar_12_fold_tiling_gpu.frag',
        );

  @override
  F0707Socolar12FoldTilingMetadata get metadata => F0707Socolar12FoldTilingMetadata.instance;

  @override
  List<F0707Socolar12FoldTilingPreset> get presets => F0707Socolar12FoldTilingPresets.all;

  @override
  List<F0707Socolar12FoldTilingVariant> get variants => F0707Socolar12FoldTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
