// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0293_fractal_flame_ifs_linear_presets.dart';
import 'f0293_fractal_flame_ifs_linear_variants.dart';
import 'f0293_fractal_flame_ifs_linear_metadata.dart';

/// Fractal Flame IFS (linear) — IFS & Geometric Construction.
class F0293FractalFlameIfsLinear extends IFSModule {
  F0293FractalFlameIfsLinear()
      : super(
          id: 'f0293_fractal_flame_ifs_linear',
          shader: 'shaders/f0293_fractal_flame_ifs_linear_gpu.frag',
        );

  @override
  F0293FractalFlameIfsLinearMetadata get metadata => F0293FractalFlameIfsLinearMetadata.instance;

  @override
  List<F0293FractalFlameIfsLinearPreset> get presets => F0293FractalFlameIfsLinearPresets.all;

  @override
  List<F0293FractalFlameIfsLinearVariant> get variants => F0293FractalFlameIfsLinearVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
