// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0295_fractal_flame_spherical_presets.dart';
import 'f0295_fractal_flame_spherical_variants.dart';
import 'f0295_fractal_flame_spherical_metadata.dart';

/// Fractal Flame (spherical) — IFS & Geometric Construction.
class F0295FractalFlameSpherical extends IFSModule {
  F0295FractalFlameSpherical()
      : super(
          id: 'f0295_fractal_flame_spherical',
          shader: 'shaders/f0295_fractal_flame_spherical_gpu.frag',
        );

  @override
  F0295FractalFlameSphericalMetadata get metadata => F0295FractalFlameSphericalMetadata.instance;

  @override
  List<F0295FractalFlameSphericalPreset> get presets => F0295FractalFlameSphericalPresets.all;

  @override
  List<F0295FractalFlameSphericalVariant> get variants => F0295FractalFlameSphericalVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
