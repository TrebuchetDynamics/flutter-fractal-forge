// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0728_gray_scott_coral_presets.dart';
import 'f0728_gray_scott_coral_variants.dart';
import 'f0728_gray_scott_coral_metadata.dart';

/// Gray-Scott Coral — Reaction-Diffusion & Chemical.
class F0728GrayScottCoral extends CellularModule {
  F0728GrayScottCoral()
      : super(
          id: 'f0728_gray_scott_coral',
          shader: 'shaders/f0728_gray_scott_coral_gpu.frag',
        );

  @override
  F0728GrayScottCoralMetadata get metadata => F0728GrayScottCoralMetadata.instance;

  @override
  List<F0728GrayScottCoralPreset> get presets => F0728GrayScottCoralPresets.all;

  @override
  List<F0728GrayScottCoralVariant> get variants => F0728GrayScottCoralVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
