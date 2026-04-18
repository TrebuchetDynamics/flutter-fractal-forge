// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0718_danzer_7_fold_tiling_presets.dart';
import 'f0718_danzer_7_fold_tiling_variants.dart';
import 'f0718_danzer_7_fold_tiling_metadata.dart';

/// Danzer 7-Fold Tiling — Tiling & Aperiodic.
class F0718Danzer7FoldTiling extends IFSModule {
  F0718Danzer7FoldTiling()
      : super(
          id: 'f0718_danzer_7_fold_tiling',
          shader: 'shaders/f0718_danzer_7_fold_tiling_gpu.frag',
        );

  @override
  F0718Danzer7FoldTilingMetadata get metadata => F0718Danzer7FoldTilingMetadata.instance;

  @override
  List<F0718Danzer7FoldTilingPreset> get presets => F0718Danzer7FoldTilingPresets.all;

  @override
  List<F0718Danzer7FoldTilingVariant> get variants => F0718Danzer7FoldTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
