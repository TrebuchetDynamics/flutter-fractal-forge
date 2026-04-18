// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1128_fractal_flame_v27_eyefish_presets.dart';
import 'f1128_fractal_flame_v27_eyefish_variants.dart';
import 'f1128_fractal_flame_v27_eyefish_metadata.dart';

/// Fractal Flame V27 Eyefish — IFS & Geometric Construction.
class F1128FractalFlameV27Eyefish extends IFSModule {
  F1128FractalFlameV27Eyefish()
      : super(
          id: 'f1128_fractal_flame_v27_eyefish',
          shader: 'shaders/f1128_fractal_flame_v27_eyefish_gpu.frag',
        );

  @override
  F1128FractalFlameV27EyefishMetadata get metadata => F1128FractalFlameV27EyefishMetadata.instance;

  @override
  List<F1128FractalFlameV27EyefishPreset> get presets => F1128FractalFlameV27EyefishPresets.all;

  @override
  List<F1128FractalFlameV27EyefishVariant> get variants => F1128FractalFlameV27EyefishVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
