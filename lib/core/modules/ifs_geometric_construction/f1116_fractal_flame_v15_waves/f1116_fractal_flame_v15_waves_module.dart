// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1116_fractal_flame_v15_waves_presets.dart';
import 'f1116_fractal_flame_v15_waves_variants.dart';
import 'f1116_fractal_flame_v15_waves_metadata.dart';

/// Fractal Flame V15 Waves — IFS & Geometric Construction.
class F1116FractalFlameV15Waves extends IFSModule {
  F1116FractalFlameV15Waves()
      : super(
          id: 'f1116_fractal_flame_v15_waves',
          shader: 'shaders/f1116_fractal_flame_v15_waves_gpu.frag',
        );

  @override
  F1116FractalFlameV15WavesMetadata get metadata => F1116FractalFlameV15WavesMetadata.instance;

  @override
  List<F1116FractalFlameV15WavesPreset> get presets => F1116FractalFlameV15WavesPresets.all;

  @override
  List<F1116FractalFlameV15WavesVariant> get variants => F1116FractalFlameV15WavesVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
