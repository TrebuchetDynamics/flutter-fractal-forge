// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1109_fractal_flame_v8_disc_presets.dart';
import 'f1109_fractal_flame_v8_disc_variants.dart';
import 'f1109_fractal_flame_v8_disc_metadata.dart';

/// Fractal Flame V8 Disc — IFS & Geometric Construction.
class F1109FractalFlameV8Disc extends IFSModule {
  F1109FractalFlameV8Disc()
      : super(
          id: 'f1109_fractal_flame_v8_disc',
          shader: 'shaders/f1109_fractal_flame_v8_disc_gpu.frag',
        );

  @override
  F1109FractalFlameV8DiscMetadata get metadata => F1109FractalFlameV8DiscMetadata.instance;

  @override
  List<F1109FractalFlameV8DiscPreset> get presets => F1109FractalFlameV8DiscPresets.all;

  @override
  List<F1109FractalFlameV8DiscVariant> get variants => F1109FractalFlameV8DiscVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
