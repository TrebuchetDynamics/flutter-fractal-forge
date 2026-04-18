// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1108_fractal_flame_v7_heart_presets.dart';
import 'f1108_fractal_flame_v7_heart_variants.dart';
import 'f1108_fractal_flame_v7_heart_metadata.dart';

/// Fractal Flame V7 Heart — IFS & Geometric Construction.
class F1108FractalFlameV7Heart extends IFSModule {
  F1108FractalFlameV7Heart()
      : super(
          id: 'f1108_fractal_flame_v7_heart',
          shader: 'shaders/f1108_fractal_flame_v7_heart_gpu.frag',
        );

  @override
  F1108FractalFlameV7HeartMetadata get metadata => F1108FractalFlameV7HeartMetadata.instance;

  @override
  List<F1108FractalFlameV7HeartPreset> get presets => F1108FractalFlameV7HeartPresets.all;

  @override
  List<F1108FractalFlameV7HeartVariant> get variants => F1108FractalFlameV7HeartVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
