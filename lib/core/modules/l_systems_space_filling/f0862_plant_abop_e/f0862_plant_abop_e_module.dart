// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0862_plant_abop_e_presets.dart';
import 'f0862_plant_abop_e_variants.dart';
import 'f0862_plant_abop_e_metadata.dart';

/// Plant ABOP E — L-Systems & Space-Filling.
class F0862PlantAbopE extends LSystemModule {
  F0862PlantAbopE()
      : super(
          id: 'f0862_plant_abop_e',
          shader: 'shaders/f0862_plant_abop_e_gpu.frag',
        );

  @override
  F0862PlantAbopEMetadata get metadata => F0862PlantAbopEMetadata.instance;

  @override
  List<F0862PlantAbopEPreset> get presets => F0862PlantAbopEPresets.all;

  @override
  List<F0862PlantAbopEVariant> get variants => F0862PlantAbopEVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
