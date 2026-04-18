// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1104_fractal_flame_v3_swirl_presets.dart';
import 'f1104_fractal_flame_v3_swirl_variants.dart';
import 'f1104_fractal_flame_v3_swirl_metadata.dart';

/// Fractal Flame V3 Swirl — IFS & Geometric Construction.
class F1104FractalFlameV3Swirl extends IFSModule {
  F1104FractalFlameV3Swirl()
      : super(
          id: 'f1104_fractal_flame_v3_swirl',
          shader: 'shaders/f1104_fractal_flame_v3_swirl_gpu.frag',
        );

  @override
  F1104FractalFlameV3SwirlMetadata get metadata => F1104FractalFlameV3SwirlMetadata.instance;

  @override
  List<F1104FractalFlameV3SwirlPreset> get presets => F1104FractalFlameV3SwirlPresets.all;

  @override
  List<F1104FractalFlameV3SwirlVariant> get variants => F1104FractalFlameV3SwirlVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
