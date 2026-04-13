// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0341_clifford_nebula_presets.dart';
import 'f0341_clifford_nebula_variants.dart';
import 'f0341_clifford_nebula_metadata.dart';

/// Clifford Nebula — Strange Attractors.
class F0341CliffordNebula extends AttractorModule {
  F0341CliffordNebula()
      : super(
          id: 'f0341_clifford_nebula',
          shader: 'shaders/f0341_clifford_nebula_gpu.frag',
        );

  @override
  F0341CliffordNebulaMetadata get metadata => F0341CliffordNebulaMetadata.instance;

  @override
  List<F0341CliffordNebulaPreset> get presets => F0341CliffordNebulaPresets.all;

  @override
  List<F0341CliffordNebulaVariant> get variants => F0341CliffordNebulaVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
