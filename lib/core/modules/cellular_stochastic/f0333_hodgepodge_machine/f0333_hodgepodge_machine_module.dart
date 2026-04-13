// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0333_hodgepodge_machine_presets.dart';
import 'f0333_hodgepodge_machine_variants.dart';
import 'f0333_hodgepodge_machine_metadata.dart';

/// Hodgepodge Machine — Cellular & Stochastic.
class F0333HodgepodgeMachine extends CellularModule {
  F0333HodgepodgeMachine()
      : super(
          id: 'f0333_hodgepodge_machine',
          shader: 'shaders/f0333_hodgepodge_machine_gpu.frag',
        );

  @override
  F0333HodgepodgeMachineMetadata get metadata => F0333HodgepodgeMachineMetadata.instance;

  @override
  List<F0333HodgepodgeMachinePreset> get presets => F0333HodgepodgeMachinePresets.all;

  @override
  List<F0333HodgepodgeMachineVariant> get variants => F0333HodgepodgeMachineVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
