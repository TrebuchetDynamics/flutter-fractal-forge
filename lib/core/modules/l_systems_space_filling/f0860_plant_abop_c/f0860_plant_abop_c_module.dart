// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0860_plant_abop_c_presets.dart';
import 'f0860_plant_abop_c_variants.dart';
import 'f0860_plant_abop_c_metadata.dart';

/// Plant ABOP C — L-Systems & Space-Filling.
class F0860PlantAbopC extends LSystemModule {
  F0860PlantAbopC()
      : super(
          id: 'f0860_plant_abop_c',
          shader: 'shaders/f0860_plant_abop_c_gpu.frag',
        );

  @override
  F0860PlantAbopCMetadata get metadata => F0860PlantAbopCMetadata.instance;

  @override
  List<F0860PlantAbopCPreset> get presets => F0860PlantAbopCPresets.all;

  @override
  List<F0860PlantAbopCVariant> get variants => F0860PlantAbopCVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
