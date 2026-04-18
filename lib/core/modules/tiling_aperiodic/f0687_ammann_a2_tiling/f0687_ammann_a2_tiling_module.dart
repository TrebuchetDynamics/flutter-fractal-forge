// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0687_ammann_a2_tiling_presets.dart';
import 'f0687_ammann_a2_tiling_variants.dart';
import 'f0687_ammann_a2_tiling_metadata.dart';

/// Ammann A2 Tiling — Tiling & Aperiodic.
class F0687AmmannA2Tiling extends IFSModule {
  F0687AmmannA2Tiling()
      : super(
          id: 'f0687_ammann_a2_tiling',
          shader: 'shaders/f0687_ammann_a2_tiling_gpu.frag',
        );

  @override
  F0687AmmannA2TilingMetadata get metadata => F0687AmmannA2TilingMetadata.instance;

  @override
  List<F0687AmmannA2TilingPreset> get presets => F0687AmmannA2TilingPresets.all;

  @override
  List<F0687AmmannA2TilingVariant> get variants => F0687AmmannA2TilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
