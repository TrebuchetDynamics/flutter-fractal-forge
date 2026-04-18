// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0714_tribonacci_substitution_presets.dart';
import 'f0714_tribonacci_substitution_variants.dart';
import 'f0714_tribonacci_substitution_metadata.dart';

/// Tribonacci Substitution — Tiling & Aperiodic.
class F0714TribonacciSubstitution extends IFSModule {
  F0714TribonacciSubstitution()
      : super(
          id: 'f0714_tribonacci_substitution',
          shader: 'shaders/f0714_tribonacci_substitution_gpu.frag',
        );

  @override
  F0714TribonacciSubstitutionMetadata get metadata => F0714TribonacciSubstitutionMetadata.instance;

  @override
  List<F0714TribonacciSubstitutionPreset> get presets => F0714TribonacciSubstitutionPresets.all;

  @override
  List<F0714TribonacciSubstitutionVariant> get variants => F0714TribonacciSubstitutionVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
