// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0690_ammann_a5_tiling_presets.dart';
import 'f0690_ammann_a5_tiling_variants.dart';
import 'f0690_ammann_a5_tiling_metadata.dart';

/// Ammann A5 Tiling — Tiling & Aperiodic.
class F0690AmmannA5Tiling extends IFSModule {
  F0690AmmannA5Tiling()
      : super(
          id: 'f0690_ammann_a5_tiling',
          shader: 'shaders/f0690_ammann_a5_tiling_gpu.frag',
        );

  @override
  F0690AmmannA5TilingMetadata get metadata => F0690AmmannA5TilingMetadata.instance;

  @override
  List<F0690AmmannA5TilingPreset> get presets => F0690AmmannA5TilingPresets.all;

  @override
  List<F0690AmmannA5TilingVariant> get variants => F0690AmmannA5TilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
