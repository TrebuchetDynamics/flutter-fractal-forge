// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0750_brusselator_hopf_presets.dart';
import 'f0750_brusselator_hopf_variants.dart';
import 'f0750_brusselator_hopf_metadata.dart';

/// Brusselator Hopf — Reaction-Diffusion & Chemical.
class F0750BrusselatorHopf extends CellularModule {
  F0750BrusselatorHopf()
      : super(
          id: 'f0750_brusselator_hopf',
          shader: 'shaders/f0750_brusselator_hopf_gpu.frag',
        );

  @override
  F0750BrusselatorHopfMetadata get metadata => F0750BrusselatorHopfMetadata.instance;

  @override
  List<F0750BrusselatorHopfPreset> get presets => F0750BrusselatorHopfPresets.all;

  @override
  List<F0750BrusselatorHopfVariant> get variants => F0750BrusselatorHopfVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
