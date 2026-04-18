// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0749_brusselator_presets.dart';
import 'f0749_brusselator_variants.dart';
import 'f0749_brusselator_metadata.dart';

/// Brusselator — Reaction-Diffusion & Chemical.
class F0749Brusselator extends CellularModule {
  F0749Brusselator()
      : super(
          id: 'f0749_brusselator',
          shader: 'shaders/f0749_brusselator_gpu.frag',
        );

  @override
  F0749BrusselatorMetadata get metadata => F0749BrusselatorMetadata.instance;

  @override
  List<F0749BrusselatorPreset> get presets => F0749BrusselatorPresets.all;

  @override
  List<F0749BrusselatorVariant> get variants => F0749BrusselatorVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
