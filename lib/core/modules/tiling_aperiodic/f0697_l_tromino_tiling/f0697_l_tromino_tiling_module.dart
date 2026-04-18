// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0697_l_tromino_tiling_presets.dart';
import 'f0697_l_tromino_tiling_variants.dart';
import 'f0697_l_tromino_tiling_metadata.dart';

/// L-Tromino Tiling — Tiling & Aperiodic.
class F0697LTrominoTiling extends IFSModule {
  F0697LTrominoTiling()
      : super(
          id: 'f0697_l_tromino_tiling',
          shader: 'shaders/f0697_l_tromino_tiling_gpu.frag',
        );

  @override
  F0697LTrominoTilingMetadata get metadata => F0697LTrominoTilingMetadata.instance;

  @override
  List<F0697LTrominoTilingPreset> get presets => F0697LTrominoTilingPresets.all;

  @override
  List<F0697LTrominoTilingVariant> get variants => F0697LTrominoTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
