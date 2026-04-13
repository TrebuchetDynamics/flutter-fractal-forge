// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0208_clifford_attractor_presets.dart';
import 'f0208_clifford_attractor_variants.dart';
import 'f0208_clifford_attractor_metadata.dart';

/// Clifford Attractor — Strange Attractors.
class F0208CliffordAttractor extends AttractorModule {
  F0208CliffordAttractor()
      : super(
          id: 'f0208_clifford_attractor',
          shader: 'shaders/f0208_clifford_attractor_gpu.frag',
        );

  @override
  F0208CliffordAttractorMetadata get metadata => F0208CliffordAttractorMetadata.instance;

  @override
  List<F0208CliffordAttractorPreset> get presets => F0208CliffordAttractorPresets.all;

  @override
  List<F0208CliffordAttractorVariant> get variants => F0208CliffordAttractorVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
