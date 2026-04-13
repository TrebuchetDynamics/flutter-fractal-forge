// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0294_fractal_flame_sinusoidal_presets.dart';
import 'f0294_fractal_flame_sinusoidal_variants.dart';
import 'f0294_fractal_flame_sinusoidal_metadata.dart';

/// Fractal Flame (sinusoidal) — IFS & Geometric Construction.
class F0294FractalFlameSinusoidal extends IFSModule {
  F0294FractalFlameSinusoidal()
      : super(
          id: 'f0294_fractal_flame_sinusoidal',
          shader: 'shaders/f0294_fractal_flame_sinusoidal_gpu.frag',
        );

  @override
  F0294FractalFlameSinusoidalMetadata get metadata => F0294FractalFlameSinusoidalMetadata.instance;

  @override
  List<F0294FractalFlameSinusoidalPreset> get presets => F0294FractalFlameSinusoidalPresets.all;

  @override
  List<F0294FractalFlameSinusoidalVariant> get variants => F0294FractalFlameSinusoidalVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
