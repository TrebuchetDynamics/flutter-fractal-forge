// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1139_fractal_flame_v38_ngon_presets.dart';
import 'f1139_fractal_flame_v38_ngon_variants.dart';
import 'f1139_fractal_flame_v38_ngon_metadata.dart';

/// Fractal Flame V38 Ngon — IFS & Geometric Construction.
class F1139FractalFlameV38Ngon extends IFSModule {
  F1139FractalFlameV38Ngon()
      : super(
          id: 'f1139_fractal_flame_v38_ngon',
          shader: 'shaders/f1139_fractal_flame_v38_ngon_gpu.frag',
        );

  @override
  F1139FractalFlameV38NgonMetadata get metadata => F1139FractalFlameV38NgonMetadata.instance;

  @override
  List<F1139FractalFlameV38NgonPreset> get presets => F1139FractalFlameV38NgonPresets.all;

  @override
  List<F1139FractalFlameV38NgonVariant> get variants => F1139FractalFlameV38NgonVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
