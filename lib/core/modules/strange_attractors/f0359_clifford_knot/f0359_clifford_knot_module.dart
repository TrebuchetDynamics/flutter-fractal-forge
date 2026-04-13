// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0359_clifford_knot_presets.dart';
import 'f0359_clifford_knot_variants.dart';
import 'f0359_clifford_knot_metadata.dart';

/// Clifford Knot — Strange Attractors.
class F0359CliffordKnot extends AttractorModule {
  F0359CliffordKnot()
      : super(
          id: 'f0359_clifford_knot',
          shader: 'shaders/f0359_clifford_knot_gpu.frag',
        );

  @override
  F0359CliffordKnotMetadata get metadata => F0359CliffordKnotMetadata.instance;

  @override
  List<F0359CliffordKnotPreset> get presets => F0359CliffordKnotPresets.all;

  @override
  List<F0359CliffordKnotVariant> get variants => F0359CliffordKnotVariants.all;

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
