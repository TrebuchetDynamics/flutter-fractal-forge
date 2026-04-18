// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0731_gray_scott_bubbles_presets.dart';
import 'f0731_gray_scott_bubbles_variants.dart';
import 'f0731_gray_scott_bubbles_metadata.dart';

/// Gray-Scott Bubbles — Reaction-Diffusion & Chemical.
class F0731GrayScottBubbles extends CellularModule {
  F0731GrayScottBubbles()
      : super(
          id: 'f0731_gray_scott_bubbles',
          shader: 'shaders/f0731_gray_scott_bubbles_gpu.frag',
        );

  @override
  F0731GrayScottBubblesMetadata get metadata => F0731GrayScottBubblesMetadata.instance;

  @override
  List<F0731GrayScottBubblesPreset> get presets => F0731GrayScottBubblesPresets.all;

  @override
  List<F0731GrayScottBubblesVariant> get variants => F0731GrayScottBubblesVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
