// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1141_fractal_flame_v40_rectangles_presets.dart';
import 'f1141_fractal_flame_v40_rectangles_variants.dart';
import 'f1141_fractal_flame_v40_rectangles_metadata.dart';

/// Fractal Flame V40 Rectangles — IFS & Geometric Construction.
class F1141FractalFlameV40Rectangles extends IFSModule {
  F1141FractalFlameV40Rectangles()
      : super(
          id: 'f1141_fractal_flame_v40_rectangles',
          shader: 'shaders/f1141_fractal_flame_v40_rectangles_gpu.frag',
        );

  @override
  F1141FractalFlameV40RectanglesMetadata get metadata => F1141FractalFlameV40RectanglesMetadata.instance;

  @override
  List<F1141FractalFlameV40RectanglesPreset> get presets => F1141FractalFlameV40RectanglesPresets.all;

  @override
  List<F1141FractalFlameV40RectanglesVariant> get variants => F1141FractalFlameV40RectanglesVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
