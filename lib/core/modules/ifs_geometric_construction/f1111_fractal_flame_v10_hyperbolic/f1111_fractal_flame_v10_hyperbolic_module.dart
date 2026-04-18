// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1111_fractal_flame_v10_hyperbolic_presets.dart';
import 'f1111_fractal_flame_v10_hyperbolic_variants.dart';
import 'f1111_fractal_flame_v10_hyperbolic_metadata.dart';

/// Fractal Flame V10 Hyperbolic — IFS & Geometric Construction.
class F1111FractalFlameV10Hyperbolic extends IFSModule {
  F1111FractalFlameV10Hyperbolic()
      : super(
          id: 'f1111_fractal_flame_v10_hyperbolic',
          shader: 'shaders/f1111_fractal_flame_v10_hyperbolic_gpu.frag',
        );

  @override
  F1111FractalFlameV10HyperbolicMetadata get metadata => F1111FractalFlameV10HyperbolicMetadata.instance;

  @override
  List<F1111FractalFlameV10HyperbolicPreset> get presets => F1111FractalFlameV10HyperbolicPresets.all;

  @override
  List<F1111FractalFlameV10HyperbolicVariant> get variants => F1111FractalFlameV10HyperbolicVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
