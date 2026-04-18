// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1135_fractal_flame_v34_blur_presets.dart';
import 'f1135_fractal_flame_v34_blur_variants.dart';
import 'f1135_fractal_flame_v34_blur_metadata.dart';

/// Fractal Flame V34 Blur — IFS & Geometric Construction.
class F1135FractalFlameV34Blur extends IFSModule {
  F1135FractalFlameV34Blur()
      : super(
          id: 'f1135_fractal_flame_v34_blur',
          shader: 'shaders/f1135_fractal_flame_v34_blur_gpu.frag',
        );

  @override
  F1135FractalFlameV34BlurMetadata get metadata => F1135FractalFlameV34BlurMetadata.instance;

  @override
  List<F1135FractalFlameV34BlurPreset> get presets => F1135FractalFlameV34BlurPresets.all;

  @override
  List<F1135FractalFlameV34BlurVariant> get variants => F1135FractalFlameV34BlurVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
