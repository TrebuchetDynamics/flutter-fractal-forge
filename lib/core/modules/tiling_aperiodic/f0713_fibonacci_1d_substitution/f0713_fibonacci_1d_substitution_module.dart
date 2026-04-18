// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0713_fibonacci_1d_substitution_presets.dart';
import 'f0713_fibonacci_1d_substitution_variants.dart';
import 'f0713_fibonacci_1d_substitution_metadata.dart';

/// Fibonacci 1D Substitution — Tiling & Aperiodic.
class F0713Fibonacci1dSubstitution extends IFSModule {
  F0713Fibonacci1dSubstitution()
      : super(
          id: 'f0713_fibonacci_1d_substitution',
          shader: 'shaders/f0713_fibonacci_1d_substitution_gpu.frag',
        );

  @override
  F0713Fibonacci1dSubstitutionMetadata get metadata => F0713Fibonacci1dSubstitutionMetadata.instance;

  @override
  List<F0713Fibonacci1dSubstitutionPreset> get presets => F0713Fibonacci1dSubstitutionPresets.all;

  @override
  List<F0713Fibonacci1dSubstitutionVariant> get variants => F0713Fibonacci1dSubstitutionVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
