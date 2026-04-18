// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1113_fractal_flame_v12_ex_presets.dart';
import 'f1113_fractal_flame_v12_ex_variants.dart';
import 'f1113_fractal_flame_v12_ex_metadata.dart';

/// Fractal Flame V12 Ex — IFS & Geometric Construction.
class F1113FractalFlameV12Ex extends IFSModule {
  F1113FractalFlameV12Ex()
      : super(
          id: 'f1113_fractal_flame_v12_ex',
          shader: 'shaders/f1113_fractal_flame_v12_ex_gpu.frag',
        );

  @override
  F1113FractalFlameV12ExMetadata get metadata => F1113FractalFlameV12ExMetadata.instance;

  @override
  List<F1113FractalFlameV12ExPreset> get presets => F1113FractalFlameV12ExPresets.all;

  @override
  List<F1113FractalFlameV12ExVariant> get variants => F1113FractalFlameV12ExVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
