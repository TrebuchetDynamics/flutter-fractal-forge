// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1138_fractal_flame_v37_pie_presets.dart';
import 'f1138_fractal_flame_v37_pie_variants.dart';
import 'f1138_fractal_flame_v37_pie_metadata.dart';

/// Fractal Flame V37 Pie — IFS & Geometric Construction.
class F1138FractalFlameV37Pie extends IFSModule {
  F1138FractalFlameV37Pie()
      : super(
          id: 'f1138_fractal_flame_v37_pie',
          shader: 'shaders/f1138_fractal_flame_v37_pie_gpu.frag',
        );

  @override
  F1138FractalFlameV37PieMetadata get metadata => F1138FractalFlameV37PieMetadata.instance;

  @override
  List<F1138FractalFlameV37PiePreset> get presets => F1138FractalFlameV37PiePresets.all;

  @override
  List<F1138FractalFlameV37PieVariant> get variants => F1138FractalFlameV37PieVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
