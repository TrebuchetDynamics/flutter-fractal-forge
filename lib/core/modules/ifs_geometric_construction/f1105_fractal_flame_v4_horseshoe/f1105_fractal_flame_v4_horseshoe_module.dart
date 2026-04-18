// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1105_fractal_flame_v4_horseshoe_presets.dart';
import 'f1105_fractal_flame_v4_horseshoe_variants.dart';
import 'f1105_fractal_flame_v4_horseshoe_metadata.dart';

/// Fractal Flame V4 Horseshoe — IFS & Geometric Construction.
class F1105FractalFlameV4Horseshoe extends IFSModule {
  F1105FractalFlameV4Horseshoe()
      : super(
          id: 'f1105_fractal_flame_v4_horseshoe',
          shader: 'shaders/f1105_fractal_flame_v4_horseshoe_gpu.frag',
        );

  @override
  F1105FractalFlameV4HorseshoeMetadata get metadata => F1105FractalFlameV4HorseshoeMetadata.instance;

  @override
  List<F1105FractalFlameV4HorseshoePreset> get presets => F1105FractalFlameV4HorseshoePresets.all;

  @override
  List<F1105FractalFlameV4HorseshoeVariant> get variants => F1105FractalFlameV4HorseshoeVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
