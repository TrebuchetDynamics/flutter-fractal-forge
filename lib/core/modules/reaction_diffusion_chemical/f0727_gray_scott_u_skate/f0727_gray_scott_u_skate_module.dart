// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0727_gray_scott_u_skate_presets.dart';
import 'f0727_gray_scott_u_skate_variants.dart';
import 'f0727_gray_scott_u_skate_metadata.dart';

/// Gray-Scott U-Skate — Reaction-Diffusion & Chemical.
class F0727GrayScottUSkate extends CellularModule {
  F0727GrayScottUSkate()
      : super(
          id: 'f0727_gray_scott_u_skate',
          shader: 'shaders/f0727_gray_scott_u_skate_gpu.frag',
        );

  @override
  F0727GrayScottUSkateMetadata get metadata => F0727GrayScottUSkateMetadata.instance;

  @override
  List<F0727GrayScottUSkatePreset> get presets => F0727GrayScottUSkatePresets.all;

  @override
  List<F0727GrayScottUSkateVariant> get variants => F0727GrayScottUSkateVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
