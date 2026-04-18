// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0725_gray_scott_worms_presets.dart';
import 'f0725_gray_scott_worms_variants.dart';
import 'f0725_gray_scott_worms_metadata.dart';

/// Gray-Scott Worms — Reaction-Diffusion & Chemical.
class F0725GrayScottWorms extends CellularModule {
  F0725GrayScottWorms()
      : super(
          id: 'f0725_gray_scott_worms',
          shader: 'shaders/f0725_gray_scott_worms_gpu.frag',
        );

  @override
  F0725GrayScottWormsMetadata get metadata => F0725GrayScottWormsMetadata.instance;

  @override
  List<F0725GrayScottWormsPreset> get presets => F0725GrayScottWormsPresets.all;

  @override
  List<F0725GrayScottWormsVariant> get variants => F0725GrayScottWormsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
