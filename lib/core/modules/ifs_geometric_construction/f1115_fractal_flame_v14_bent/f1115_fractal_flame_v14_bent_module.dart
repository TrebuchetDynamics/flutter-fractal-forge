// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1115_fractal_flame_v14_bent_presets.dart';
import 'f1115_fractal_flame_v14_bent_variants.dart';
import 'f1115_fractal_flame_v14_bent_metadata.dart';

/// Fractal Flame V14 Bent — IFS & Geometric Construction.
class F1115FractalFlameV14Bent extends IFSModule {
  F1115FractalFlameV14Bent()
      : super(
          id: 'f1115_fractal_flame_v14_bent',
          shader: 'shaders/f1115_fractal_flame_v14_bent_gpu.frag',
        );

  @override
  F1115FractalFlameV14BentMetadata get metadata => F1115FractalFlameV14BentMetadata.instance;

  @override
  List<F1115FractalFlameV14BentPreset> get presets => F1115FractalFlameV14BentPresets.all;

  @override
  List<F1115FractalFlameV14BentVariant> get variants => F1115FractalFlameV14BentVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
