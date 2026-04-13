// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0368_clifford_ocean_presets.dart';
import 'f0368_clifford_ocean_variants.dart';
import 'f0368_clifford_ocean_metadata.dart';

/// Clifford Ocean — Strange Attractors.
class F0368CliffordOcean extends AttractorModule {
  F0368CliffordOcean()
      : super(
          id: 'f0368_clifford_ocean',
          shader: 'shaders/f0368_clifford_ocean_gpu.frag',
        );

  @override
  F0368CliffordOceanMetadata get metadata => F0368CliffordOceanMetadata.instance;

  @override
  List<F0368CliffordOceanPreset> get presets => F0368CliffordOceanPresets.all;

  @override
  List<F0368CliffordOceanVariant> get variants => F0368CliffordOceanVariants.all;

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
