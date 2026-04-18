// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0726_gray_scott_mazes_presets.dart';
import 'f0726_gray_scott_mazes_variants.dart';
import 'f0726_gray_scott_mazes_metadata.dart';

/// Gray-Scott Mazes — Reaction-Diffusion & Chemical.
class F0726GrayScottMazes extends CellularModule {
  F0726GrayScottMazes()
      : super(
          id: 'f0726_gray_scott_mazes',
          shader: 'shaders/f0726_gray_scott_mazes_gpu.frag',
        );

  @override
  F0726GrayScottMazesMetadata get metadata => F0726GrayScottMazesMetadata.instance;

  @override
  List<F0726GrayScottMazesPreset> get presets => F0726GrayScottMazesPresets.all;

  @override
  List<F0726GrayScottMazesVariant> get variants => F0726GrayScottMazesVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
