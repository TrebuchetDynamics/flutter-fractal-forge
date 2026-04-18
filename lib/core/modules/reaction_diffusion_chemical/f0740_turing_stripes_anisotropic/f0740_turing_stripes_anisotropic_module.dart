// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0740_turing_stripes_anisotropic_presets.dart';
import 'f0740_turing_stripes_anisotropic_variants.dart';
import 'f0740_turing_stripes_anisotropic_metadata.dart';

/// Turing Stripes (Anisotropic) — Reaction-Diffusion & Chemical.
class F0740TuringStripesAnisotropic extends CellularModule {
  F0740TuringStripesAnisotropic()
      : super(
          id: 'f0740_turing_stripes_anisotropic',
          shader: 'shaders/f0740_turing_stripes_anisotropic_gpu.frag',
        );

  @override
  F0740TuringStripesAnisotropicMetadata get metadata => F0740TuringStripesAnisotropicMetadata.instance;

  @override
  List<F0740TuringStripesAnisotropicPreset> get presets => F0740TuringStripesAnisotropicPresets.all;

  @override
  List<F0740TuringStripesAnisotropicVariant> get variants => F0740TuringStripesAnisotropicVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
