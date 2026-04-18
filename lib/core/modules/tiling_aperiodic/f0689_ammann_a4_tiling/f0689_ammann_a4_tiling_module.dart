// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0689_ammann_a4_tiling_presets.dart';
import 'f0689_ammann_a4_tiling_variants.dart';
import 'f0689_ammann_a4_tiling_metadata.dart';

/// Ammann A4 Tiling — Tiling & Aperiodic.
class F0689AmmannA4Tiling extends IFSModule {
  F0689AmmannA4Tiling()
      : super(
          id: 'f0689_ammann_a4_tiling',
          shader: 'shaders/f0689_ammann_a4_tiling_gpu.frag',
        );

  @override
  F0689AmmannA4TilingMetadata get metadata => F0689AmmannA4TilingMetadata.instance;

  @override
  List<F0689AmmannA4TilingPreset> get presets => F0689AmmannA4TilingPresets.all;

  @override
  List<F0689AmmannA4TilingVariant> get variants => F0689AmmannA4TilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
