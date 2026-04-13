// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0231_heighway_dragon_l_system_presets.dart';
import 'f0231_heighway_dragon_l_system_variants.dart';
import 'f0231_heighway_dragon_l_system_metadata.dart';

/// Heighway Dragon L-system — L-Systems & Space-Filling.
class F0231HeighwayDragonLSystem extends LSystemModule {
  F0231HeighwayDragonLSystem()
      : super(
          id: 'f0231_heighway_dragon_l_system',
          shader: 'shaders/f0231_heighway_dragon_l_system_gpu.frag',
        );

  @override
  F0231HeighwayDragonLSystemMetadata get metadata => F0231HeighwayDragonLSystemMetadata.instance;

  @override
  List<F0231HeighwayDragonLSystemPreset> get presets => F0231HeighwayDragonLSystemPresets.all;

  @override
  List<F0231HeighwayDragonLSystemVariant> get variants => F0231HeighwayDragonLSystemVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
