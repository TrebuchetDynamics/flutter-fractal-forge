// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1123_fractal_flame_v22_fan_presets.dart';
import 'f1123_fractal_flame_v22_fan_variants.dart';
import 'f1123_fractal_flame_v22_fan_metadata.dart';

/// Fractal Flame V22 Fan — IFS & Geometric Construction.
class F1123FractalFlameV22Fan extends IFSModule {
  F1123FractalFlameV22Fan()
      : super(
          id: 'f1123_fractal_flame_v22_fan',
          shader: 'shaders/f1123_fractal_flame_v22_fan_gpu.frag',
        );

  @override
  F1123FractalFlameV22FanMetadata get metadata => F1123FractalFlameV22FanMetadata.instance;

  @override
  List<F1123FractalFlameV22FanPreset> get presets => F1123FractalFlameV22FanPresets.all;

  @override
  List<F1123FractalFlameV22FanVariant> get variants => F1123FractalFlameV22FanVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
