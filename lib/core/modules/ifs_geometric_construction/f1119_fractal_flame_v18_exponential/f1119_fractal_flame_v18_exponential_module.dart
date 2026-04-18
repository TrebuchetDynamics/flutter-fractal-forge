// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1119_fractal_flame_v18_exponential_presets.dart';
import 'f1119_fractal_flame_v18_exponential_variants.dart';
import 'f1119_fractal_flame_v18_exponential_metadata.dart';

/// Fractal Flame V18 Exponential — IFS & Geometric Construction.
class F1119FractalFlameV18Exponential extends IFSModule {
  F1119FractalFlameV18Exponential()
      : super(
          id: 'f1119_fractal_flame_v18_exponential',
          shader: 'shaders/f1119_fractal_flame_v18_exponential_gpu.frag',
        );

  @override
  F1119FractalFlameV18ExponentialMetadata get metadata => F1119FractalFlameV18ExponentialMetadata.instance;

  @override
  List<F1119FractalFlameV18ExponentialPreset> get presets => F1119FractalFlameV18ExponentialPresets.all;

  @override
  List<F1119FractalFlameV18ExponentialVariant> get variants => F1119FractalFlameV18ExponentialVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
