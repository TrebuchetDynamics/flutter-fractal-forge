// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0054_l_system_presets.dart';
import 'f0054_l_system_variants.dart';
import 'f0054_l_system_metadata.dart';

/// Lü System — Strange Attractors.
class F0054LSystem extends AttractorModule {
  F0054LSystem()
      : super(
          id: 'f0054_l_system',
          shader: 'shaders/f0054_l_system_gpu.frag',
        );

  @override
  F0054LSystemMetadata get metadata => F0054LSystemMetadata.instance;

  @override
  List<F0054LSystemPreset> get presets => F0054LSystemPresets.all;

  @override
  List<F0054LSystemVariant> get variants => F0054LSystemVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
