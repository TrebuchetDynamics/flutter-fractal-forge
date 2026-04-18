// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1122_fractal_flame_v21_rings_presets.dart';
import 'f1122_fractal_flame_v21_rings_variants.dart';
import 'f1122_fractal_flame_v21_rings_metadata.dart';

/// Fractal Flame V21 Rings — IFS & Geometric Construction.
class F1122FractalFlameV21Rings extends IFSModule {
  F1122FractalFlameV21Rings()
      : super(
          id: 'f1122_fractal_flame_v21_rings',
          shader: 'shaders/f1122_fractal_flame_v21_rings_gpu.frag',
        );

  @override
  F1122FractalFlameV21RingsMetadata get metadata => F1122FractalFlameV21RingsMetadata.instance;

  @override
  List<F1122FractalFlameV21RingsPreset> get presets => F1122FractalFlameV21RingsPresets.all;

  @override
  List<F1122FractalFlameV21RingsVariant> get variants => F1122FractalFlameV21RingsVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
