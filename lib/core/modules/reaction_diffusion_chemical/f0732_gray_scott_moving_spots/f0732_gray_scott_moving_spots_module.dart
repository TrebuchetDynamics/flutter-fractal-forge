// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0732_gray_scott_moving_spots_presets.dart';
import 'f0732_gray_scott_moving_spots_variants.dart';
import 'f0732_gray_scott_moving_spots_metadata.dart';

/// Gray-Scott Moving Spots — Reaction-Diffusion & Chemical.
class F0732GrayScottMovingSpots extends CellularModule {
  F0732GrayScottMovingSpots()
      : super(
          id: 'f0732_gray_scott_moving_spots',
          shader: 'shaders/f0732_gray_scott_moving_spots_gpu.frag',
        );

  @override
  F0732GrayScottMovingSpotsMetadata get metadata => F0732GrayScottMovingSpotsMetadata.instance;

  @override
  List<F0732GrayScottMovingSpotsPreset> get presets => F0732GrayScottMovingSpotsPresets.all;

  @override
  List<F0732GrayScottMovingSpotsVariant> get variants => F0732GrayScottMovingSpotsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
