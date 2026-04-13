// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0080_coullet_system_presets.dart';
import 'f0080_coullet_system_variants.dart';
import 'f0080_coullet_system_metadata.dart';

/// Coullet System — Strange Attractors.
class F0080CoulletSystem extends AttractorModule {
  F0080CoulletSystem()
      : super(
          id: 'f0080_coullet_system',
          shader: 'shaders/f0080_coullet_system_gpu.frag',
        );

  @override
  F0080CoulletSystemMetadata get metadata => F0080CoulletSystemMetadata.instance;

  @override
  List<F0080CoulletSystemPreset> get presets => F0080CoulletSystemPresets.all;

  @override
  List<F0080CoulletSystemVariant> get variants => F0080CoulletSystemVariants.all;

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
