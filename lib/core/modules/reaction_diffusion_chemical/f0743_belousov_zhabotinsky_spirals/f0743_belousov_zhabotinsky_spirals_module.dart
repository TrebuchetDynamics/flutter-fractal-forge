// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0743_belousov_zhabotinsky_spirals_presets.dart';
import 'f0743_belousov_zhabotinsky_spirals_variants.dart';
import 'f0743_belousov_zhabotinsky_spirals_metadata.dart';

/// Belousov-Zhabotinsky Spirals — Reaction-Diffusion & Chemical.
class F0743BelousovZhabotinskySpirals extends CellularModule {
  F0743BelousovZhabotinskySpirals()
      : super(
          id: 'f0743_belousov_zhabotinsky_spirals',
          shader: 'shaders/f0743_belousov_zhabotinsky_spirals_gpu.frag',
        );

  @override
  F0743BelousovZhabotinskySpiralsMetadata get metadata => F0743BelousovZhabotinskySpiralsMetadata.instance;

  @override
  List<F0743BelousovZhabotinskySpiralsPreset> get presets => F0743BelousovZhabotinskySpiralsPresets.all;

  @override
  List<F0743BelousovZhabotinskySpiralsVariant> get variants => F0743BelousovZhabotinskySpiralsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
