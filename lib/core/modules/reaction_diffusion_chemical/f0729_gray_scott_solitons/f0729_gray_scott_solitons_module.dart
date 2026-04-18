// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0729_gray_scott_solitons_presets.dart';
import 'f0729_gray_scott_solitons_variants.dart';
import 'f0729_gray_scott_solitons_metadata.dart';

/// Gray-Scott Solitons — Reaction-Diffusion & Chemical.
class F0729GrayScottSolitons extends CellularModule {
  F0729GrayScottSolitons()
      : super(
          id: 'f0729_gray_scott_solitons',
          shader: 'shaders/f0729_gray_scott_solitons_gpu.frag',
        );

  @override
  F0729GrayScottSolitonsMetadata get metadata => F0729GrayScottSolitonsMetadata.instance;

  @override
  List<F0729GrayScottSolitonsPreset> get presets => F0729GrayScottSolitonsPresets.all;

  @override
  List<F0729GrayScottSolitonsVariant> get variants => F0729GrayScottSolitonsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
