// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0346_clifford_vortex_presets.dart';
import 'f0346_clifford_vortex_variants.dart';
import 'f0346_clifford_vortex_metadata.dart';

/// Clifford Vortex — Strange Attractors.
class F0346CliffordVortex extends AttractorModule {
  F0346CliffordVortex()
      : super(
          id: 'f0346_clifford_vortex',
          shader: 'shaders/f0346_clifford_vortex_gpu.frag',
        );

  @override
  F0346CliffordVortexMetadata get metadata => F0346CliffordVortexMetadata.instance;

  @override
  List<F0346CliffordVortexPreset> get presets => F0346CliffordVortexPresets.all;

  @override
  List<F0346CliffordVortexVariant> get variants => F0346CliffordVortexVariants.all;

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
