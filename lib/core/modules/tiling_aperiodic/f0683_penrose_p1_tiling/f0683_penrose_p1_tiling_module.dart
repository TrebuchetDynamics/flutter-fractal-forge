// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0683_penrose_p1_tiling_presets.dart';
import 'f0683_penrose_p1_tiling_variants.dart';
import 'f0683_penrose_p1_tiling_metadata.dart';

/// Penrose P1 Tiling — Tiling & Aperiodic.
class F0683PenroseP1Tiling extends IFSModule {
  F0683PenroseP1Tiling()
      : super(
          id: 'f0683_penrose_p1_tiling',
          shader: 'shaders/f0683_penrose_p1_tiling_gpu.frag',
        );

  @override
  F0683PenroseP1TilingMetadata get metadata => F0683PenroseP1TilingMetadata.instance;

  @override
  List<F0683PenroseP1TilingPreset> get presets => F0683PenroseP1TilingPresets.all;

  @override
  List<F0683PenroseP1TilingVariant> get variants => F0683PenroseP1TilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
