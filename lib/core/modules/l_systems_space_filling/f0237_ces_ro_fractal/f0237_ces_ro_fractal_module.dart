// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0237_ces_ro_fractal_presets.dart';
import 'f0237_ces_ro_fractal_variants.dart';
import 'f0237_ces_ro_fractal_metadata.dart';

/// Cesàro Fractal — L-Systems & Space-Filling.
class F0237CesRoFractal extends LSystemModule {
  F0237CesRoFractal()
      : super(
          id: 'f0237_ces_ro_fractal',
          shader: 'shaders/f0237_ces_ro_fractal_gpu.frag',
        );

  @override
  F0237CesRoFractalMetadata get metadata => F0237CesRoFractalMetadata.instance;

  @override
  List<F0237CesRoFractalPreset> get presets => F0237CesRoFractalPresets.all;

  @override
  List<F0237CesRoFractalVariant> get variants => F0237CesRoFractalVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
