// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1103_fractal_flame_v2_spherical_presets.dart';
import 'f1103_fractal_flame_v2_spherical_variants.dart';
import 'f1103_fractal_flame_v2_spherical_metadata.dart';

/// Fractal Flame V2 Spherical — IFS & Geometric Construction.
class F1103FractalFlameV2Spherical extends IFSModule {
  F1103FractalFlameV2Spherical()
      : super(
          id: 'f1103_fractal_flame_v2_spherical',
          shader: 'shaders/f1103_fractal_flame_v2_spherical_gpu.frag',
        );

  @override
  F1103FractalFlameV2SphericalMetadata get metadata => F1103FractalFlameV2SphericalMetadata.instance;

  @override
  List<F1103FractalFlameV2SphericalPreset> get presets => F1103FractalFlameV2SphericalPresets.all;

  @override
  List<F1103FractalFlameV2SphericalVariant> get variants => F1103FractalFlameV2SphericalVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
