// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0734_gray_scott_chaos_presets.dart';
import 'f0734_gray_scott_chaos_variants.dart';
import 'f0734_gray_scott_chaos_metadata.dart';

/// Gray-Scott Chaos — Reaction-Diffusion & Chemical.
class F0734GrayScottChaos extends CellularModule {
  F0734GrayScottChaos()
      : super(
          id: 'f0734_gray_scott_chaos',
          shader: 'shaders/f0734_gray_scott_chaos_gpu.frag',
        );

  @override
  F0734GrayScottChaosMetadata get metadata => F0734GrayScottChaosMetadata.instance;

  @override
  List<F0734GrayScottChaosPreset> get presets => F0734GrayScottChaosPresets.all;

  @override
  List<F0734GrayScottChaosVariant> get variants => F0734GrayScottChaosVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
