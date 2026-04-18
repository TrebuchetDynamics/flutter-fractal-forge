// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1131_fractal_flame_v30_perspective_presets.dart';
import 'f1131_fractal_flame_v30_perspective_variants.dart';
import 'f1131_fractal_flame_v30_perspective_metadata.dart';

/// Fractal Flame V30 Perspective — IFS & Geometric Construction.
class F1131FractalFlameV30Perspective extends IFSModule {
  F1131FractalFlameV30Perspective()
      : super(
          id: 'f1131_fractal_flame_v30_perspective',
          shader: 'shaders/f1131_fractal_flame_v30_perspective_gpu.frag',
        );

  @override
  F1131FractalFlameV30PerspectiveMetadata get metadata => F1131FractalFlameV30PerspectiveMetadata.instance;

  @override
  List<F1131FractalFlameV30PerspectivePreset> get presets => F1131FractalFlameV30PerspectivePresets.all;

  @override
  List<F1131FractalFlameV30PerspectiveVariant> get variants => F1131FractalFlameV30PerspectiveVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
