// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0360_clifford_whirl_presets.dart';
import 'f0360_clifford_whirl_variants.dart';
import 'f0360_clifford_whirl_metadata.dart';

/// Clifford Whirl — Strange Attractors.
class F0360CliffordWhirl extends AttractorModule {
  F0360CliffordWhirl()
      : super(
          id: 'f0360_clifford_whirl',
          shader: 'shaders/f0360_clifford_whirl_gpu.frag',
        );

  @override
  F0360CliffordWhirlMetadata get metadata => F0360CliffordWhirlMetadata.instance;

  @override
  List<F0360CliffordWhirlPreset> get presets => F0360CliffordWhirlPresets.all;

  @override
  List<F0360CliffordWhirlVariant> get variants => F0360CliffordWhirlVariants.all;

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
