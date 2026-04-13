// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0339_clifford_butterfly_presets.dart';
import 'f0339_clifford_butterfly_variants.dart';
import 'f0339_clifford_butterfly_metadata.dart';

/// Clifford Butterfly — Strange Attractors.
class F0339CliffordButterfly extends AttractorModule {
  F0339CliffordButterfly()
      : super(
          id: 'f0339_clifford_butterfly',
          shader: 'shaders/f0339_clifford_butterfly_gpu.frag',
        );

  @override
  F0339CliffordButterflyMetadata get metadata => F0339CliffordButterflyMetadata.instance;

  @override
  List<F0339CliffordButterflyPreset> get presets => F0339CliffordButterflyPresets.all;

  @override
  List<F0339CliffordButterflyVariant> get variants => F0339CliffordButterflyVariants.all;

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
