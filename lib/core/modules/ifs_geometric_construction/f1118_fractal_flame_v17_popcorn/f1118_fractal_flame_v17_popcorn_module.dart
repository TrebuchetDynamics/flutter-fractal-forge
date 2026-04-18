// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1118_fractal_flame_v17_popcorn_presets.dart';
import 'f1118_fractal_flame_v17_popcorn_variants.dart';
import 'f1118_fractal_flame_v17_popcorn_metadata.dart';

/// Fractal Flame V17 Popcorn — IFS & Geometric Construction.
class F1118FractalFlameV17Popcorn extends IFSModule {
  F1118FractalFlameV17Popcorn()
      : super(
          id: 'f1118_fractal_flame_v17_popcorn',
          shader: 'shaders/f1118_fractal_flame_v17_popcorn_gpu.frag',
        );

  @override
  F1118FractalFlameV17PopcornMetadata get metadata => F1118FractalFlameV17PopcornMetadata.instance;

  @override
  List<F1118FractalFlameV17PopcornPreset> get presets => F1118FractalFlameV17PopcornPresets.all;

  @override
  List<F1118FractalFlameV17PopcornVariant> get variants => F1118FractalFlameV17PopcornVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
