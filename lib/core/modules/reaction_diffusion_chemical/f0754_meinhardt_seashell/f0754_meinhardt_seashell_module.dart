// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0754_meinhardt_seashell_presets.dart';
import 'f0754_meinhardt_seashell_variants.dart';
import 'f0754_meinhardt_seashell_metadata.dart';

/// Meinhardt Seashell — Reaction-Diffusion & Chemical.
class F0754MeinhardtSeashell extends CellularModule {
  F0754MeinhardtSeashell()
      : super(
          id: 'f0754_meinhardt_seashell',
          shader: 'shaders/f0754_meinhardt_seashell_gpu.frag',
        );

  @override
  F0754MeinhardtSeashellMetadata get metadata => F0754MeinhardtSeashellMetadata.instance;

  @override
  List<F0754MeinhardtSeashellPreset> get presets => F0754MeinhardtSeashellPresets.all;

  @override
  List<F0754MeinhardtSeashellVariant> get variants => F0754MeinhardtSeashellVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
