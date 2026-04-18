// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0716_thue_morse_2d_tiling_presets.dart';
import 'f0716_thue_morse_2d_tiling_variants.dart';
import 'f0716_thue_morse_2d_tiling_metadata.dart';

/// Thue-Morse 2D Tiling — Tiling & Aperiodic.
class F0716ThueMorse2dTiling extends IFSModule {
  F0716ThueMorse2dTiling()
      : super(
          id: 'f0716_thue_morse_2d_tiling',
          shader: 'shaders/f0716_thue_morse_2d_tiling_gpu.frag',
        );

  @override
  F0716ThueMorse2dTilingMetadata get metadata => F0716ThueMorse2dTilingMetadata.instance;

  @override
  List<F0716ThueMorse2dTilingPreset> get presets => F0716ThueMorse2dTilingPresets.all;

  @override
  List<F0716ThueMorse2dTilingVariant> get variants => F0716ThueMorse2dTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
