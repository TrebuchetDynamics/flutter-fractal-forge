// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0352_clifford_coral_presets.dart';
import 'f0352_clifford_coral_variants.dart';
import 'f0352_clifford_coral_metadata.dart';

/// Clifford Coral — Strange Attractors.
class F0352CliffordCoral extends AttractorModule {
  F0352CliffordCoral()
      : super(
          id: 'f0352_clifford_coral',
          shader: 'shaders/f0352_clifford_coral_gpu.frag',
        );

  @override
  F0352CliffordCoralMetadata get metadata => F0352CliffordCoralMetadata.instance;

  @override
  List<F0352CliffordCoralPreset> get presets => F0352CliffordCoralPresets.all;

  @override
  List<F0352CliffordCoralVariant> get variants => F0352CliffordCoralVariants.all;

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
