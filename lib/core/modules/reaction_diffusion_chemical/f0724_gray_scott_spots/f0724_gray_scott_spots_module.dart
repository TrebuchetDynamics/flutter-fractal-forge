// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0724_gray_scott_spots_presets.dart';
import 'f0724_gray_scott_spots_variants.dart';
import 'f0724_gray_scott_spots_metadata.dart';

/// Gray-Scott Spots — Reaction-Diffusion & Chemical.
class F0724GrayScottSpots extends CellularModule {
  F0724GrayScottSpots()
      : super(
          id: 'f0724_gray_scott_spots',
          shader: 'shaders/f0724_gray_scott_spots_gpu.frag',
        );

  @override
  F0724GrayScottSpotsMetadata get metadata => F0724GrayScottSpotsMetadata.instance;

  @override
  List<F0724GrayScottSpotsPreset> get presets => F0724GrayScottSpotsPresets.all;

  @override
  List<F0724GrayScottSpotsVariant> get variants => F0724GrayScottSpotsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
