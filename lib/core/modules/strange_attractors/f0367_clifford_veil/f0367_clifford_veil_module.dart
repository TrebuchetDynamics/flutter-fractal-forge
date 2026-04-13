// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0367_clifford_veil_presets.dart';
import 'f0367_clifford_veil_variants.dart';
import 'f0367_clifford_veil_metadata.dart';

/// Clifford Veil — Strange Attractors.
class F0367CliffordVeil extends AttractorModule {
  F0367CliffordVeil()
      : super(
          id: 'f0367_clifford_veil',
          shader: 'shaders/f0367_clifford_veil_gpu.frag',
        );

  @override
  F0367CliffordVeilMetadata get metadata => F0367CliffordVeilMetadata.instance;

  @override
  List<F0367CliffordVeilPreset> get presets => F0367CliffordVeilPresets.all;

  @override
  List<F0367CliffordVeilVariant> get variants => F0367CliffordVeilVariants.all;

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
