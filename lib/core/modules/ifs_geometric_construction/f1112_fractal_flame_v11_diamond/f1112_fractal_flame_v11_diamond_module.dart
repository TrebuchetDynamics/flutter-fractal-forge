// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1112_fractal_flame_v11_diamond_presets.dart';
import 'f1112_fractal_flame_v11_diamond_variants.dart';
import 'f1112_fractal_flame_v11_diamond_metadata.dart';

/// Fractal Flame V11 Diamond — IFS & Geometric Construction.
class F1112FractalFlameV11Diamond extends IFSModule {
  F1112FractalFlameV11Diamond()
      : super(
          id: 'f1112_fractal_flame_v11_diamond',
          shader: 'shaders/f1112_fractal_flame_v11_diamond_gpu.frag',
        );

  @override
  F1112FractalFlameV11DiamondMetadata get metadata => F1112FractalFlameV11DiamondMetadata.instance;

  @override
  List<F1112FractalFlameV11DiamondPreset> get presets => F1112FractalFlameV11DiamondPresets.all;

  @override
  List<F1112FractalFlameV11DiamondVariant> get variants => F1112FractalFlameV11DiamondVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
