// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0779_pisot_plastic_number_presets.dart';
import 'f0779_pisot_plastic_number_variants.dart';
import 'f0779_pisot_plastic_number_metadata.dart';

/// Pisot Plastic Number — Number-Theory Fractals.
class F0779PisotPlasticNumber extends CellularModule {
  F0779PisotPlasticNumber()
      : super(
          id: 'f0779_pisot_plastic_number',
          shader: 'shaders/f0779_pisot_plastic_number_gpu.frag',
        );

  @override
  F0779PisotPlasticNumberMetadata get metadata => F0779PisotPlasticNumberMetadata.instance;

  @override
  List<F0779PisotPlasticNumberPreset> get presets => F0779PisotPlasticNumberPresets.all;

  @override
  List<F0779PisotPlasticNumberVariant> get variants => F0779PisotPlasticNumberVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
