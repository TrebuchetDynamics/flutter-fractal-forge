// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0688_ammann_a3_tiling_presets.dart';
import 'f0688_ammann_a3_tiling_variants.dart';
import 'f0688_ammann_a3_tiling_metadata.dart';

/// Ammann A3 Tiling — Tiling & Aperiodic.
class F0688AmmannA3Tiling extends IFSModule {
  F0688AmmannA3Tiling()
      : super(
          id: 'f0688_ammann_a3_tiling',
          shader: 'shaders/f0688_ammann_a3_tiling_gpu.frag',
        );

  @override
  F0688AmmannA3TilingMetadata get metadata => F0688AmmannA3TilingMetadata.instance;

  @override
  List<F0688AmmannA3TilingPreset> get presets => F0688AmmannA3TilingPresets.all;

  @override
  List<F0688AmmannA3TilingVariant> get variants => F0688AmmannA3TilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
