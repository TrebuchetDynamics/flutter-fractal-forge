// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0730_gray_scott_stripes_presets.dart';
import 'f0730_gray_scott_stripes_variants.dart';
import 'f0730_gray_scott_stripes_metadata.dart';

/// Gray-Scott Stripes — Reaction-Diffusion & Chemical.
class F0730GrayScottStripes extends CellularModule {
  F0730GrayScottStripes()
      : super(
          id: 'f0730_gray_scott_stripes',
          shader: 'shaders/f0730_gray_scott_stripes_gpu.frag',
        );

  @override
  F0730GrayScottStripesMetadata get metadata => F0730GrayScottStripesMetadata.instance;

  @override
  List<F0730GrayScottStripesPreset> get presets => F0730GrayScottStripesPresets.all;

  @override
  List<F0730GrayScottStripesVariant> get variants => F0730GrayScottStripesVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
