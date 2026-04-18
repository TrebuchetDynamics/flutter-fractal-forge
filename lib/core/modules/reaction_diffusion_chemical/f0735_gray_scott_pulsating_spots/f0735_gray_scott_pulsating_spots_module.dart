// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0735_gray_scott_pulsating_spots_presets.dart';
import 'f0735_gray_scott_pulsating_spots_variants.dart';
import 'f0735_gray_scott_pulsating_spots_metadata.dart';

/// Gray-Scott Pulsating Spots — Reaction-Diffusion & Chemical.
class F0735GrayScottPulsatingSpots extends CellularModule {
  F0735GrayScottPulsatingSpots()
      : super(
          id: 'f0735_gray_scott_pulsating_spots',
          shader: 'shaders/f0735_gray_scott_pulsating_spots_gpu.frag',
        );

  @override
  F0735GrayScottPulsatingSpotsMetadata get metadata => F0735GrayScottPulsatingSpotsMetadata.instance;

  @override
  List<F0735GrayScottPulsatingSpotsPreset> get presets => F0735GrayScottPulsatingSpotsPresets.all;

  @override
  List<F0735GrayScottPulsatingSpotsVariant> get variants => F0735GrayScottPulsatingSpotsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
