// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0863_plant_abop_f_variant_presets.dart';
import 'f0863_plant_abop_f_variant_variants.dart';
import 'f0863_plant_abop_f_variant_metadata.dart';

/// Plant ABOP F (variant) — L-Systems & Space-Filling.
class F0863PlantAbopFVariant extends LSystemModule {
  F0863PlantAbopFVariant()
      : super(
          id: 'f0863_plant_abop_f_variant',
          shader: 'shaders/f0863_plant_abop_f_variant_gpu.frag',
        );

  @override
  F0863PlantAbopFVariantMetadata get metadata => F0863PlantAbopFVariantMetadata.instance;

  @override
  List<F0863PlantAbopFVariantPreset> get presets => F0863PlantAbopFVariantPresets.all;

  @override
  List<F0863PlantAbopFVariantVariant> get variants => F0863PlantAbopFVariantVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
