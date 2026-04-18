// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1136_fractal_flame_v35_gaussian_blur_presets.dart';
import 'f1136_fractal_flame_v35_gaussian_blur_variants.dart';
import 'f1136_fractal_flame_v35_gaussian_blur_metadata.dart';

/// Fractal Flame V35 Gaussian Blur — IFS & Geometric Construction.
class F1136FractalFlameV35GaussianBlur extends IFSModule {
  F1136FractalFlameV35GaussianBlur()
      : super(
          id: 'f1136_fractal_flame_v35_gaussian_blur',
          shader: 'shaders/f1136_fractal_flame_v35_gaussian_blur_gpu.frag',
        );

  @override
  F1136FractalFlameV35GaussianBlurMetadata get metadata => F1136FractalFlameV35GaussianBlurMetadata.instance;

  @override
  List<F1136FractalFlameV35GaussianBlurPreset> get presets => F1136FractalFlameV35GaussianBlurPresets.all;

  @override
  List<F1136FractalFlameV35GaussianBlurVariant> get variants => F1136FractalFlameV35GaussianBlurVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
