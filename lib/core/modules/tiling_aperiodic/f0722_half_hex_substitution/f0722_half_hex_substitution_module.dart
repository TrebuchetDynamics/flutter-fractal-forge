// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0722_half_hex_substitution_presets.dart';
import 'f0722_half_hex_substitution_variants.dart';
import 'f0722_half_hex_substitution_metadata.dart';

/// Half-Hex Substitution — Tiling & Aperiodic.
class F0722HalfHexSubstitution extends IFSModule {
  F0722HalfHexSubstitution()
      : super(
          id: 'f0722_half_hex_substitution',
          shader: 'shaders/f0722_half_hex_substitution_gpu.frag',
        );

  @override
  F0722HalfHexSubstitutionMetadata get metadata => F0722HalfHexSubstitutionMetadata.instance;

  @override
  List<F0722HalfHexSubstitutionPreset> get presets => F0722HalfHexSubstitutionPresets.all;

  @override
  List<F0722HalfHexSubstitutionVariant> get variants => F0722HalfHexSubstitutionVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
