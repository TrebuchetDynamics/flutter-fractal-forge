// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1127_fractal_flame_v26_rings2_presets.dart';
import 'f1127_fractal_flame_v26_rings2_variants.dart';
import 'f1127_fractal_flame_v26_rings2_metadata.dart';

/// Fractal Flame V26 Rings2 — IFS & Geometric Construction.
class F1127FractalFlameV26Rings2 extends IFSModule {
  F1127FractalFlameV26Rings2()
      : super(
          id: 'f1127_fractal_flame_v26_rings2',
          shader: 'shaders/f1127_fractal_flame_v26_rings2_gpu.frag',
        );

  @override
  F1127FractalFlameV26Rings2Metadata get metadata => F1127FractalFlameV26Rings2Metadata.instance;

  @override
  List<F1127FractalFlameV26Rings2Preset> get presets => F1127FractalFlameV26Rings2Presets.all;

  @override
  List<F1127FractalFlameV26Rings2Variant> get variants => F1127FractalFlameV26Rings2Variants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
