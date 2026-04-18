// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0715_rauzy_fractal_tiling_presets.dart';
import 'f0715_rauzy_fractal_tiling_variants.dart';
import 'f0715_rauzy_fractal_tiling_metadata.dart';

/// Rauzy Fractal Tiling — Tiling & Aperiodic.
class F0715RauzyFractalTiling extends IFSModule {
  F0715RauzyFractalTiling()
      : super(
          id: 'f0715_rauzy_fractal_tiling',
          shader: 'shaders/f0715_rauzy_fractal_tiling_gpu.frag',
        );

  @override
  F0715RauzyFractalTilingMetadata get metadata => F0715RauzyFractalTilingMetadata.instance;

  @override
  List<F0715RauzyFractalTilingPreset> get presets => F0715RauzyFractalTilingPresets.all;

  @override
  List<F0715RauzyFractalTilingVariant> get variants => F0715RauzyFractalTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
