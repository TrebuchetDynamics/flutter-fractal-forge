// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1027_fhp_lattice_gas_presets.dart';
import 'f1027_fhp_lattice_gas_variants.dart';
import 'f1027_fhp_lattice_gas_metadata.dart';

/// FHP Lattice Gas — Cellular & Stochastic.
class F1027FhpLatticeGas extends CellularModule {
  F1027FhpLatticeGas()
      : super(
          id: 'f1027_fhp_lattice_gas',
          shader: 'shaders/f1027_fhp_lattice_gas_gpu.frag',
        );

  @override
  F1027FhpLatticeGasMetadata get metadata => F1027FhpLatticeGasMetadata.instance;

  @override
  List<F1027FhpLatticeGasPreset> get presets => F1027FhpLatticeGasPresets.all;

  @override
  List<F1027FhpLatticeGasVariant> get variants => F1027FhpLatticeGasVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
