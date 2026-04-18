// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0696_chair_tiling_presets.dart';
import 'f0696_chair_tiling_variants.dart';
import 'f0696_chair_tiling_metadata.dart';

/// Chair Tiling — Tiling & Aperiodic.
class F0696ChairTiling extends IFSModule {
  F0696ChairTiling()
      : super(
          id: 'f0696_chair_tiling',
          shader: 'shaders/f0696_chair_tiling_gpu.frag',
        );

  @override
  F0696ChairTilingMetadata get metadata => F0696ChairTilingMetadata.instance;

  @override
  List<F0696ChairTilingPreset> get presets => F0696ChairTilingPresets.all;

  @override
  List<F0696ChairTilingVariant> get variants => F0696ChairTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
