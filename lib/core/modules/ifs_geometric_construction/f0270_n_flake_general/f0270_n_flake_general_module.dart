// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0270_n_flake_general_presets.dart';
import 'f0270_n_flake_general_variants.dart';
import 'f0270_n_flake_general_metadata.dart';

/// N-flake (general) — IFS & Geometric Construction.
class F0270NFlakeGeneral extends IFSModule {
  F0270NFlakeGeneral()
      : super(
          id: 'f0270_n_flake_general',
          shader: 'shaders/f0270_n_flake_general_gpu.frag',
        );

  @override
  F0270NFlakeGeneralMetadata get metadata => F0270NFlakeGeneralMetadata.instance;

  @override
  List<F0270NFlakeGeneralPreset> get presets => F0270NFlakeGeneralPresets.all;

  @override
  List<F0270NFlakeGeneralVariant> get variants => F0270NFlakeGeneralVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
