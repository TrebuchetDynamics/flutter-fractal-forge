// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0361_clifford_infinity_presets.dart';
import 'f0361_clifford_infinity_variants.dart';
import 'f0361_clifford_infinity_metadata.dart';

/// Clifford Infinity — Strange Attractors.
class F0361CliffordInfinity extends AttractorModule {
  F0361CliffordInfinity()
      : super(
          id: 'f0361_clifford_infinity',
          shader: 'shaders/f0361_clifford_infinity_gpu.frag',
        );

  @override
  F0361CliffordInfinityMetadata get metadata => F0361CliffordInfinityMetadata.instance;

  @override
  List<F0361CliffordInfinityPreset> get presets => F0361CliffordInfinityPresets.all;

  @override
  List<F0361CliffordInfinityVariant> get variants => F0361CliffordInfinityVariants.all;

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
