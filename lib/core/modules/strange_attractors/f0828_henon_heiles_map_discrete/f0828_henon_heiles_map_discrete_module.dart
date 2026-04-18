// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0828_henon_heiles_map_discrete_presets.dart';
import 'f0828_henon_heiles_map_discrete_variants.dart';
import 'f0828_henon_heiles_map_discrete_metadata.dart';

/// Henon-Heiles Map (Discrete) — Strange Attractors.
class F0828HenonHeilesMapDiscrete extends AttractorModule {
  F0828HenonHeilesMapDiscrete()
      : super(
          id: 'f0828_henon_heiles_map_discrete',
          shader: 'shaders/f0828_henon_heiles_map_discrete_gpu.frag',
        );

  @override
  F0828HenonHeilesMapDiscreteMetadata get metadata => F0828HenonHeilesMapDiscreteMetadata.instance;

  @override
  List<F0828HenonHeilesMapDiscretePreset> get presets => F0828HenonHeilesMapDiscretePresets.all;

  @override
  List<F0828HenonHeilesMapDiscreteVariant> get variants => F0828HenonHeilesMapDiscreteVariants.all;

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
