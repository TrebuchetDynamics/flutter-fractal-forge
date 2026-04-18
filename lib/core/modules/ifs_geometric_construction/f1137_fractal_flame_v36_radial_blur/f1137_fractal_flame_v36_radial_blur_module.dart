// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1137_fractal_flame_v36_radial_blur_presets.dart';
import 'f1137_fractal_flame_v36_radial_blur_variants.dart';
import 'f1137_fractal_flame_v36_radial_blur_metadata.dart';

/// Fractal Flame V36 Radial Blur — IFS & Geometric Construction.
class F1137FractalFlameV36RadialBlur extends IFSModule {
  F1137FractalFlameV36RadialBlur()
      : super(
          id: 'f1137_fractal_flame_v36_radial_blur',
          shader: 'shaders/f1137_fractal_flame_v36_radial_blur_gpu.frag',
        );

  @override
  F1137FractalFlameV36RadialBlurMetadata get metadata => F1137FractalFlameV36RadialBlurMetadata.instance;

  @override
  List<F1137FractalFlameV36RadialBlurPreset> get presets => F1137FractalFlameV36RadialBlurPresets.all;

  @override
  List<F1137FractalFlameV36RadialBlurVariant> get variants => F1137FractalFlameV36RadialBlurVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
