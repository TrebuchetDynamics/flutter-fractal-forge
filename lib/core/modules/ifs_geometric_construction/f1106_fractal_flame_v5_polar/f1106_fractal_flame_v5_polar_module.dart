// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1106_fractal_flame_v5_polar_presets.dart';
import 'f1106_fractal_flame_v5_polar_variants.dart';
import 'f1106_fractal_flame_v5_polar_metadata.dart';

/// Fractal Flame V5 Polar — IFS & Geometric Construction.
class F1106FractalFlameV5Polar extends IFSModule {
  F1106FractalFlameV5Polar()
      : super(
          id: 'f1106_fractal_flame_v5_polar',
          shader: 'shaders/f1106_fractal_flame_v5_polar_gpu.frag',
        );

  @override
  F1106FractalFlameV5PolarMetadata get metadata => F1106FractalFlameV5PolarMetadata.instance;

  @override
  List<F1106FractalFlameV5PolarPreset> get presets => F1106FractalFlameV5PolarPresets.all;

  @override
  List<F1106FractalFlameV5PolarVariant> get variants => F1106FractalFlameV5PolarVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
