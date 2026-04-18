// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1133_fractal_flame_v32_julian_presets.dart';
import 'f1133_fractal_flame_v32_julian_variants.dart';
import 'f1133_fractal_flame_v32_julian_metadata.dart';

/// Fractal Flame V32 JuliaN — IFS & Geometric Construction.
class F1133FractalFlameV32Julian extends IFSModule {
  F1133FractalFlameV32Julian()
      : super(
          id: 'f1133_fractal_flame_v32_julian',
          shader: 'shaders/f1133_fractal_flame_v32_julian_gpu.frag',
        );

  @override
  F1133FractalFlameV32JulianMetadata get metadata => F1133FractalFlameV32JulianMetadata.instance;

  @override
  List<F1133FractalFlameV32JulianPreset> get presets => F1133FractalFlameV32JulianPresets.all;

  @override
  List<F1133FractalFlameV32JulianVariant> get variants => F1133FractalFlameV32JulianVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
