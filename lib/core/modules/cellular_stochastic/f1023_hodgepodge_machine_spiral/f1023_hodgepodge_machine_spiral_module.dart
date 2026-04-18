// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1023_hodgepodge_machine_spiral_presets.dart';
import 'f1023_hodgepodge_machine_spiral_variants.dart';
import 'f1023_hodgepodge_machine_spiral_metadata.dart';

/// Hodgepodge Machine (Spiral) — Cellular & Stochastic.
class F1023HodgepodgeMachineSpiral extends CellularModule {
  F1023HodgepodgeMachineSpiral()
      : super(
          id: 'f1023_hodgepodge_machine_spiral',
          shader: 'shaders/f1023_hodgepodge_machine_spiral_gpu.frag',
        );

  @override
  F1023HodgepodgeMachineSpiralMetadata get metadata => F1023HodgepodgeMachineSpiralMetadata.instance;

  @override
  List<F1023HodgepodgeMachineSpiralPreset> get presets => F1023HodgepodgeMachineSpiralPresets.all;

  @override
  List<F1023HodgepodgeMachineSpiralVariant> get variants => F1023HodgepodgeMachineSpiralVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
