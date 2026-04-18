// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1121_fractal_flame_v20_cosine_presets.dart';
import 'f1121_fractal_flame_v20_cosine_variants.dart';
import 'f1121_fractal_flame_v20_cosine_metadata.dart';

/// Fractal Flame V20 Cosine — IFS & Geometric Construction.
class F1121FractalFlameV20Cosine extends IFSModule {
  F1121FractalFlameV20Cosine()
      : super(
          id: 'f1121_fractal_flame_v20_cosine',
          shader: 'shaders/f1121_fractal_flame_v20_cosine_gpu.frag',
        );

  @override
  F1121FractalFlameV20CosineMetadata get metadata => F1121FractalFlameV20CosineMetadata.instance;

  @override
  List<F1121FractalFlameV20CosinePreset> get presets => F1121FractalFlameV20CosinePresets.all;

  @override
  List<F1121FractalFlameV20CosineVariant> get variants => F1121FractalFlameV20CosineVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
