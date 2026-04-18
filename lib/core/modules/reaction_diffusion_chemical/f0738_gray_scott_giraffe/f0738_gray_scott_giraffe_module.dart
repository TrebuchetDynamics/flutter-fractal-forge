// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0738_gray_scott_giraffe_presets.dart';
import 'f0738_gray_scott_giraffe_variants.dart';
import 'f0738_gray_scott_giraffe_metadata.dart';

/// Gray-Scott Giraffe — Reaction-Diffusion & Chemical.
class F0738GrayScottGiraffe extends CellularModule {
  F0738GrayScottGiraffe()
      : super(
          id: 'f0738_gray_scott_giraffe',
          shader: 'shaders/f0738_gray_scott_giraffe_gpu.frag',
        );

  @override
  F0738GrayScottGiraffeMetadata get metadata => F0738GrayScottGiraffeMetadata.instance;

  @override
  List<F0738GrayScottGiraffePreset> get presets => F0738GrayScottGiraffePresets.all;

  @override
  List<F0738GrayScottGiraffeVariant> get variants => F0738GrayScottGiraffeVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
