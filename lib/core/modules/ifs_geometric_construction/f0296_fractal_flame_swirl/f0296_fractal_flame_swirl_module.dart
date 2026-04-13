// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0296_fractal_flame_swirl_presets.dart';
import 'f0296_fractal_flame_swirl_variants.dart';
import 'f0296_fractal_flame_swirl_metadata.dart';

/// Fractal Flame (swirl) — IFS & Geometric Construction.
class F0296FractalFlameSwirl extends IFSModule {
  F0296FractalFlameSwirl()
      : super(
          id: 'f0296_fractal_flame_swirl',
          shader: 'shaders/f0296_fractal_flame_swirl_gpu.frag',
        );

  @override
  F0296FractalFlameSwirlMetadata get metadata => F0296FractalFlameSwirlMetadata.instance;

  @override
  List<F0296FractalFlameSwirlPreset> get presets => F0296FractalFlameSwirlPresets.all;

  @override
  List<F0296FractalFlameSwirlVariant> get variants => F0296FractalFlameSwirlVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
