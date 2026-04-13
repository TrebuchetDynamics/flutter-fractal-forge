// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0357_clifford_torus_presets.dart';
import 'f0357_clifford_torus_variants.dart';
import 'f0357_clifford_torus_metadata.dart';

/// Clifford Torus — Strange Attractors.
class F0357CliffordTorus extends AttractorModule {
  F0357CliffordTorus()
      : super(
          id: 'f0357_clifford_torus',
          shader: 'shaders/f0357_clifford_torus_gpu.frag',
        );

  @override
  F0357CliffordTorusMetadata get metadata => F0357CliffordTorusMetadata.instance;

  @override
  List<F0357CliffordTorusPreset> get presets => F0357CliffordTorusPresets.all;

  @override
  List<F0357CliffordTorusVariant> get variants => F0357CliffordTorusVariants.all;

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
