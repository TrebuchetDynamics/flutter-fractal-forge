// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0719_cyrille_tiling_presets.dart';
import 'f0719_cyrille_tiling_variants.dart';
import 'f0719_cyrille_tiling_metadata.dart';

/// Cyrille Tiling — Tiling & Aperiodic.
class F0719CyrilleTiling extends IFSModule {
  F0719CyrilleTiling()
      : super(
          id: 'f0719_cyrille_tiling',
          shader: 'shaders/f0719_cyrille_tiling_gpu.frag',
        );

  @override
  F0719CyrilleTilingMetadata get metadata => F0719CyrilleTilingMetadata.instance;

  @override
  List<F0719CyrilleTilingPreset> get presets => F0719CyrilleTilingPresets.all;

  @override
  List<F0719CyrilleTilingVariant> get variants => F0719CyrilleTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
