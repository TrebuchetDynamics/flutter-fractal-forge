// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0756_barkley_model_presets.dart';
import 'f0756_barkley_model_variants.dart';
import 'f0756_barkley_model_metadata.dart';

/// Barkley Model — Reaction-Diffusion & Chemical.
class F0756BarkleyModel extends CellularModule {
  F0756BarkleyModel()
      : super(
          id: 'f0756_barkley_model',
          shader: 'shaders/f0756_barkley_model_gpu.frag',
        );

  @override
  F0756BarkleyModelMetadata get metadata => F0756BarkleyModelMetadata.instance;

  @override
  List<F0756BarkleyModelPreset> get presets => F0756BarkleyModelPresets.all;

  @override
  List<F0756BarkleyModelVariant> get variants => F0756BarkleyModelVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
