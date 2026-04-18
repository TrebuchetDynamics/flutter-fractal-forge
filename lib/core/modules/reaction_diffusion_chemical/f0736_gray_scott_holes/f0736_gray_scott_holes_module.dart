// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0736_gray_scott_holes_presets.dart';
import 'f0736_gray_scott_holes_variants.dart';
import 'f0736_gray_scott_holes_metadata.dart';

/// Gray-Scott Holes — Reaction-Diffusion & Chemical.
class F0736GrayScottHoles extends CellularModule {
  F0736GrayScottHoles()
      : super(
          id: 'f0736_gray_scott_holes',
          shader: 'shaders/f0736_gray_scott_holes_gpu.frag',
        );

  @override
  F0736GrayScottHolesMetadata get metadata => F0736GrayScottHolesMetadata.instance;

  @override
  List<F0736GrayScottHolesPreset> get presets => F0736GrayScottHolesPresets.all;

  @override
  List<F0736GrayScottHolesVariant> get variants => F0736GrayScottHolesVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
