// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0345_clifford_flame_presets.dart';
import 'f0345_clifford_flame_variants.dart';
import 'f0345_clifford_flame_metadata.dart';

/// Clifford Flame — Strange Attractors.
class F0345CliffordFlame extends AttractorModule {
  F0345CliffordFlame()
      : super(
          id: 'f0345_clifford_flame',
          shader: 'shaders/f0345_clifford_flame_gpu.frag',
        );

  @override
  F0345CliffordFlameMetadata get metadata => F0345CliffordFlameMetadata.instance;

  @override
  List<F0345CliffordFlamePreset> get presets => F0345CliffordFlamePresets.all;

  @override
  List<F0345CliffordFlameVariant> get variants => F0345CliffordFlameVariants.all;

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
