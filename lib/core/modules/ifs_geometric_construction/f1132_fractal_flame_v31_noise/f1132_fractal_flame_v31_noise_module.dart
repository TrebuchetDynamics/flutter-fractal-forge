// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1132_fractal_flame_v31_noise_presets.dart';
import 'f1132_fractal_flame_v31_noise_variants.dart';
import 'f1132_fractal_flame_v31_noise_metadata.dart';

/// Fractal Flame V31 Noise — IFS & Geometric Construction.
class F1132FractalFlameV31Noise extends IFSModule {
  F1132FractalFlameV31Noise()
      : super(
          id: 'f1132_fractal_flame_v31_noise',
          shader: 'shaders/f1132_fractal_flame_v31_noise_gpu.frag',
        );

  @override
  F1132FractalFlameV31NoiseMetadata get metadata => F1132FractalFlameV31NoiseMetadata.instance;

  @override
  List<F1132FractalFlameV31NoisePreset> get presets => F1132FractalFlameV31NoisePresets.all;

  @override
  List<F1132FractalFlameV31NoiseVariant> get variants => F1132FractalFlameV31NoiseVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
