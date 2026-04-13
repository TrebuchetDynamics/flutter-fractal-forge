// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0245_fractal_bush_presets.dart';
import 'f0245_fractal_bush_variants.dart';
import 'f0245_fractal_bush_metadata.dart';

/// Fractal Bush — L-Systems & Space-Filling.
class F0245FractalBush extends LSystemModule {
  F0245FractalBush()
      : super(
          id: 'f0245_fractal_bush',
          shader: 'shaders/f0245_fractal_bush_gpu.frag',
        );

  @override
  F0245FractalBushMetadata get metadata => F0245FractalBushMetadata.instance;

  @override
  List<F0245FractalBushPreset> get presets => F0245FractalBushPresets.all;

  @override
  List<F0245FractalBushVariant> get variants => F0245FractalBushVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
