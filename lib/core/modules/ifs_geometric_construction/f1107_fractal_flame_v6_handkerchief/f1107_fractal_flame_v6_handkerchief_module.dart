// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1107_fractal_flame_v6_handkerchief_presets.dart';
import 'f1107_fractal_flame_v6_handkerchief_variants.dart';
import 'f1107_fractal_flame_v6_handkerchief_metadata.dart';

/// Fractal Flame V6 Handkerchief — IFS & Geometric Construction.
class F1107FractalFlameV6Handkerchief extends IFSModule {
  F1107FractalFlameV6Handkerchief()
      : super(
          id: 'f1107_fractal_flame_v6_handkerchief',
          shader: 'shaders/f1107_fractal_flame_v6_handkerchief_gpu.frag',
        );

  @override
  F1107FractalFlameV6HandkerchiefMetadata get metadata => F1107FractalFlameV6HandkerchiefMetadata.instance;

  @override
  List<F1107FractalFlameV6HandkerchiefPreset> get presets => F1107FractalFlameV6HandkerchiefPresets.all;

  @override
  List<F1107FractalFlameV6HandkerchiefVariant> get variants => F1107FractalFlameV6HandkerchiefVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
