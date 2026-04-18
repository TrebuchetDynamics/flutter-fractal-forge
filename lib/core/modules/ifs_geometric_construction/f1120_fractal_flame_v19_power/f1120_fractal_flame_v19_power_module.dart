// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1120_fractal_flame_v19_power_presets.dart';
import 'f1120_fractal_flame_v19_power_variants.dart';
import 'f1120_fractal_flame_v19_power_metadata.dart';

/// Fractal Flame V19 Power — IFS & Geometric Construction.
class F1120FractalFlameV19Power extends IFSModule {
  F1120FractalFlameV19Power()
      : super(
          id: 'f1120_fractal_flame_v19_power',
          shader: 'shaders/f1120_fractal_flame_v19_power_gpu.frag',
        );

  @override
  F1120FractalFlameV19PowerMetadata get metadata => F1120FractalFlameV19PowerMetadata.instance;

  @override
  List<F1120FractalFlameV19PowerPreset> get presets => F1120FractalFlameV19PowerPresets.all;

  @override
  List<F1120FractalFlameV19PowerVariant> get variants => F1120FractalFlameV19PowerVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
