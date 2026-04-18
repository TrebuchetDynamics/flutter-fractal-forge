// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1117_fractal_flame_v16_fisheye_presets.dart';
import 'f1117_fractal_flame_v16_fisheye_variants.dart';
import 'f1117_fractal_flame_v16_fisheye_metadata.dart';

/// Fractal Flame V16 Fisheye — IFS & Geometric Construction.
class F1117FractalFlameV16Fisheye extends IFSModule {
  F1117FractalFlameV16Fisheye()
      : super(
          id: 'f1117_fractal_flame_v16_fisheye',
          shader: 'shaders/f1117_fractal_flame_v16_fisheye_gpu.frag',
        );

  @override
  F1117FractalFlameV16FisheyeMetadata get metadata => F1117FractalFlameV16FisheyeMetadata.instance;

  @override
  List<F1117FractalFlameV16FisheyePreset> get presets => F1117FractalFlameV16FisheyePresets.all;

  @override
  List<F1117FractalFlameV16FisheyeVariant> get variants => F1117FractalFlameV16FisheyeVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
