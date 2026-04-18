// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1110_fractal_flame_v9_spiral_presets.dart';
import 'f1110_fractal_flame_v9_spiral_variants.dart';
import 'f1110_fractal_flame_v9_spiral_metadata.dart';

/// Fractal Flame V9 Spiral — IFS & Geometric Construction.
class F1110FractalFlameV9Spiral extends IFSModule {
  F1110FractalFlameV9Spiral()
      : super(
          id: 'f1110_fractal_flame_v9_spiral',
          shader: 'shaders/f1110_fractal_flame_v9_spiral_gpu.frag',
        );

  @override
  F1110FractalFlameV9SpiralMetadata get metadata => F1110FractalFlameV9SpiralMetadata.instance;

  @override
  List<F1110FractalFlameV9SpiralPreset> get presets => F1110FractalFlameV9SpiralPresets.all;

  @override
  List<F1110FractalFlameV9SpiralVariant> get variants => F1110FractalFlameV9SpiralVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
