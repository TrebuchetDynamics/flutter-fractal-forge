// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0342_clifford_spirals_presets.dart';
import 'f0342_clifford_spirals_variants.dart';
import 'f0342_clifford_spirals_metadata.dart';

/// Clifford Spirals — Strange Attractors.
class F0342CliffordSpirals extends AttractorModule {
  F0342CliffordSpirals()
      : super(
          id: 'f0342_clifford_spirals',
          shader: 'shaders/f0342_clifford_spirals_gpu.frag',
        );

  @override
  F0342CliffordSpiralsMetadata get metadata => F0342CliffordSpiralsMetadata.instance;

  @override
  List<F0342CliffordSpiralsPreset> get presets => F0342CliffordSpiralsPresets.all;

  @override
  List<F0342CliffordSpiralsVariant> get variants => F0342CliffordSpiralsVariants.all;

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
