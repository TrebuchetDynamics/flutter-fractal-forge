// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0858_plant_abop_a_presets.dart';
import 'f0858_plant_abop_a_variants.dart';
import 'f0858_plant_abop_a_metadata.dart';

/// Plant ABOP A — L-Systems & Space-Filling.
class F0858PlantAbopA extends LSystemModule {
  F0858PlantAbopA()
      : super(
          id: 'f0858_plant_abop_a',
          shader: 'shaders/f0858_plant_abop_a_gpu.frag',
        );

  @override
  F0858PlantAbopAMetadata get metadata => F0858PlantAbopAMetadata.instance;

  @override
  List<F0858PlantAbopAPreset> get presets => F0858PlantAbopAPresets.all;

  @override
  List<F0858PlantAbopAVariant> get variants => F0858PlantAbopAVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
