// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0356_clifford_swirl_presets.dart';
import 'f0356_clifford_swirl_variants.dart';
import 'f0356_clifford_swirl_metadata.dart';

/// Clifford Swirl — Strange Attractors.
class F0356CliffordSwirl extends AttractorModule {
  F0356CliffordSwirl()
      : super(
          id: 'f0356_clifford_swirl',
          shader: 'shaders/f0356_clifford_swirl_gpu.frag',
        );

  @override
  F0356CliffordSwirlMetadata get metadata => F0356CliffordSwirlMetadata.instance;

  @override
  List<F0356CliffordSwirlPreset> get presets => F0356CliffordSwirlPresets.all;

  @override
  List<F0356CliffordSwirlVariant> get variants => F0356CliffordSwirlVariants.all;

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
