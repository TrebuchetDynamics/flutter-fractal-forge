// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1114_fractal_flame_v13_julia_presets.dart';
import 'f1114_fractal_flame_v13_julia_variants.dart';
import 'f1114_fractal_flame_v13_julia_metadata.dart';

/// Fractal Flame V13 Julia — IFS & Geometric Construction.
class F1114FractalFlameV13Julia extends IFSModule {
  F1114FractalFlameV13Julia()
      : super(
          id: 'f1114_fractal_flame_v13_julia',
          shader: 'shaders/f1114_fractal_flame_v13_julia_gpu.frag',
        );

  @override
  F1114FractalFlameV13JuliaMetadata get metadata => F1114FractalFlameV13JuliaMetadata.instance;

  @override
  List<F1114FractalFlameV13JuliaPreset> get presets => F1114FractalFlameV13JuliaPresets.all;

  @override
  List<F1114FractalFlameV13JuliaVariant> get variants => F1114FractalFlameV13JuliaVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
