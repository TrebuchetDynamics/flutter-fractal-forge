// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0739_turing_spots_isotropic_presets.dart';
import 'f0739_turing_spots_isotropic_variants.dart';
import 'f0739_turing_spots_isotropic_metadata.dart';

/// Turing Spots (Isotropic) — Reaction-Diffusion & Chemical.
class F0739TuringSpotsIsotropic extends CellularModule {
  F0739TuringSpotsIsotropic()
      : super(
          id: 'f0739_turing_spots_isotropic',
          shader: 'shaders/f0739_turing_spots_isotropic_gpu.frag',
        );

  @override
  F0739TuringSpotsIsotropicMetadata get metadata => F0739TuringSpotsIsotropicMetadata.instance;

  @override
  List<F0739TuringSpotsIsotropicPreset> get presets => F0739TuringSpotsIsotropicPresets.all;

  @override
  List<F0739TuringSpotsIsotropicVariant> get variants => F0739TuringSpotsIsotropicVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
