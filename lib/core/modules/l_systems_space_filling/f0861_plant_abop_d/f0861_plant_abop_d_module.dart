// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0861_plant_abop_d_presets.dart';
import 'f0861_plant_abop_d_variants.dart';
import 'f0861_plant_abop_d_metadata.dart';

/// Plant ABOP D — L-Systems & Space-Filling.
class F0861PlantAbopD extends LSystemModule {
  F0861PlantAbopD()
      : super(
          id: 'f0861_plant_abop_d',
          shader: 'shaders/f0861_plant_abop_d_gpu.frag',
        );

  @override
  F0861PlantAbopDMetadata get metadata => F0861PlantAbopDMetadata.instance;

  @override
  List<F0861PlantAbopDPreset> get presets => F0861PlantAbopDPresets.all;

  @override
  List<F0861PlantAbopDVariant> get variants => F0861PlantAbopDVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
