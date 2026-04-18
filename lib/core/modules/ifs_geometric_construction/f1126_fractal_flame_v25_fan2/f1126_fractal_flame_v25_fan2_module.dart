// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1126_fractal_flame_v25_fan2_presets.dart';
import 'f1126_fractal_flame_v25_fan2_variants.dart';
import 'f1126_fractal_flame_v25_fan2_metadata.dart';

/// Fractal Flame V25 Fan2 — IFS & Geometric Construction.
class F1126FractalFlameV25Fan2 extends IFSModule {
  F1126FractalFlameV25Fan2()
      : super(
          id: 'f1126_fractal_flame_v25_fan2',
          shader: 'shaders/f1126_fractal_flame_v25_fan2_gpu.frag',
        );

  @override
  F1126FractalFlameV25Fan2Metadata get metadata => F1126FractalFlameV25Fan2Metadata.instance;

  @override
  List<F1126FractalFlameV25Fan2Preset> get presets => F1126FractalFlameV25Fan2Presets.all;

  @override
  List<F1126FractalFlameV25Fan2Variant> get variants => F1126FractalFlameV25Fan2Variants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
