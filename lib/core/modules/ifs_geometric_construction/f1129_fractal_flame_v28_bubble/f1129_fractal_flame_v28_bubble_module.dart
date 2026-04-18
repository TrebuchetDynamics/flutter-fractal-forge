// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1129_fractal_flame_v28_bubble_presets.dart';
import 'f1129_fractal_flame_v28_bubble_variants.dart';
import 'f1129_fractal_flame_v28_bubble_metadata.dart';

/// Fractal Flame V28 Bubble — IFS & Geometric Construction.
class F1129FractalFlameV28Bubble extends IFSModule {
  F1129FractalFlameV28Bubble()
      : super(
          id: 'f1129_fractal_flame_v28_bubble',
          shader: 'shaders/f1129_fractal_flame_v28_bubble_gpu.frag',
        );

  @override
  F1129FractalFlameV28BubbleMetadata get metadata => F1129FractalFlameV28BubbleMetadata.instance;

  @override
  List<F1129FractalFlameV28BubblePreset> get presets => F1129FractalFlameV28BubblePresets.all;

  @override
  List<F1129FractalFlameV28BubbleVariant> get variants => F1129FractalFlameV28BubbleVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
