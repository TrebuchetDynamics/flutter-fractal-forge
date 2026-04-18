// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0752_schnakenberg_model_presets.dart';
import 'f0752_schnakenberg_model_variants.dart';
import 'f0752_schnakenberg_model_metadata.dart';

/// Schnakenberg Model — Reaction-Diffusion & Chemical.
class F0752SchnakenbergModel extends CellularModule {
  F0752SchnakenbergModel()
      : super(
          id: 'f0752_schnakenberg_model',
          shader: 'shaders/f0752_schnakenberg_model_gpu.frag',
        );

  @override
  F0752SchnakenbergModelMetadata get metadata => F0752SchnakenbergModelMetadata.instance;

  @override
  List<F0752SchnakenbergModelPreset> get presets => F0752SchnakenbergModelPresets.all;

  @override
  List<F0752SchnakenbergModelVariant> get variants => F0752SchnakenbergModelVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
