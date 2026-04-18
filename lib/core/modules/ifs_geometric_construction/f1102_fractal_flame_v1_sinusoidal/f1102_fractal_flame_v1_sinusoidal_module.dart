// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1102_fractal_flame_v1_sinusoidal_presets.dart';
import 'f1102_fractal_flame_v1_sinusoidal_variants.dart';
import 'f1102_fractal_flame_v1_sinusoidal_metadata.dart';

/// Fractal Flame V1 Sinusoidal — IFS & Geometric Construction.
class F1102FractalFlameV1Sinusoidal extends IFSModule {
  F1102FractalFlameV1Sinusoidal()
      : super(
          id: 'f1102_fractal_flame_v1_sinusoidal',
          shader: 'shaders/f1102_fractal_flame_v1_sinusoidal_gpu.frag',
        );

  @override
  F1102FractalFlameV1SinusoidalMetadata get metadata => F1102FractalFlameV1SinusoidalMetadata.instance;

  @override
  List<F1102FractalFlameV1SinusoidalPreset> get presets => F1102FractalFlameV1SinusoidalPresets.all;

  @override
  List<F1102FractalFlameV1SinusoidalVariant> get variants => F1102FractalFlameV1SinusoidalVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
