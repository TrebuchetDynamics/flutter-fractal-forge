// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1101_fractal_flame_v0_linear_presets.dart';
import 'f1101_fractal_flame_v0_linear_variants.dart';
import 'f1101_fractal_flame_v0_linear_metadata.dart';

/// Fractal Flame V0 Linear — IFS & Geometric Construction.
class F1101FractalFlameV0Linear extends IFSModule {
  F1101FractalFlameV0Linear()
      : super(
          id: 'f1101_fractal_flame_v0_linear',
          shader: 'shaders/f1101_fractal_flame_v0_linear_gpu.frag',
        );

  @override
  F1101FractalFlameV0LinearMetadata get metadata => F1101FractalFlameV0LinearMetadata.instance;

  @override
  List<F1101FractalFlameV0LinearPreset> get presets => F1101FractalFlameV0LinearPresets.all;

  @override
  List<F1101FractalFlameV0LinearVariant> get variants => F1101FractalFlameV0LinearVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
