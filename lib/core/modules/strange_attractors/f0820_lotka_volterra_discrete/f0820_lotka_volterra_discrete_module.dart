// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0820_lotka_volterra_discrete_presets.dart';
import 'f0820_lotka_volterra_discrete_variants.dart';
import 'f0820_lotka_volterra_discrete_metadata.dart';

/// Lotka-Volterra Discrete — Strange Attractors.
class F0820LotkaVolterraDiscrete extends AttractorModule {
  F0820LotkaVolterraDiscrete()
      : super(
          id: 'f0820_lotka_volterra_discrete',
          shader: 'shaders/f0820_lotka_volterra_discrete_gpu.frag',
        );

  @override
  F0820LotkaVolterraDiscreteMetadata get metadata => F0820LotkaVolterraDiscreteMetadata.instance;

  @override
  List<F0820LotkaVolterraDiscretePreset> get presets => F0820LotkaVolterraDiscretePresets.all;

  @override
  List<F0820LotkaVolterraDiscreteVariant> get variants => F0820LotkaVolterraDiscreteVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
