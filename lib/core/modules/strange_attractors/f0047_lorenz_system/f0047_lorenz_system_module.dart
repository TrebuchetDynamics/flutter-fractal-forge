// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0047_lorenz_system_presets.dart';
import 'f0047_lorenz_system_variants.dart';
import 'f0047_lorenz_system_metadata.dart';

/// Lorenz System — Strange Attractors.
class F0047LorenzSystem extends AttractorModule {
  F0047LorenzSystem()
      : super(
          id: 'f0047_lorenz_system',
          shader: 'shaders/f0047_lorenz_system_gpu.frag',
        );

  @override
  F0047LorenzSystemMetadata get metadata => F0047LorenzSystemMetadata.instance;

  @override
  List<F0047LorenzSystemPreset> get presets => F0047LorenzSystemPresets.all;

  @override
  List<F0047LorenzSystemVariant> get variants => F0047LorenzSystemVariants.all;

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
