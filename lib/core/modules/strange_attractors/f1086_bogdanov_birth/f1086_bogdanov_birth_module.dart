// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1086_bogdanov_birth_presets.dart';
import 'f1086_bogdanov_birth_variants.dart';
import 'f1086_bogdanov_birth_metadata.dart';

/// Bogdanov Birth — Strange Attractors.
class F1086BogdanovBirth extends AttractorModule {
  F1086BogdanovBirth()
      : super(
          id: 'f1086_bogdanov_birth',
          shader: 'shaders/f1086_bogdanov_birth_gpu.frag',
        );

  @override
  F1086BogdanovBirthMetadata get metadata => F1086BogdanovBirthMetadata.instance;

  @override
  List<F1086BogdanovBirthPreset> get presets => F1086BogdanovBirthPresets.all;

  @override
  List<F1086BogdanovBirthVariant> get variants => F1086BogdanovBirthVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
