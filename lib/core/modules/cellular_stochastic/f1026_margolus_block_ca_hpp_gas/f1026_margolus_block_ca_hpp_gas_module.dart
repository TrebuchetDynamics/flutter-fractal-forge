// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1026_margolus_block_ca_hpp_gas_presets.dart';
import 'f1026_margolus_block_ca_hpp_gas_variants.dart';
import 'f1026_margolus_block_ca_hpp_gas_metadata.dart';

/// Margolus Block CA (HPP gas) — Cellular & Stochastic.
class F1026MargolusBlockCaHppGas extends CellularModule {
  F1026MargolusBlockCaHppGas()
      : super(
          id: 'f1026_margolus_block_ca_hpp_gas',
          shader: 'shaders/f1026_margolus_block_ca_hpp_gas_gpu.frag',
        );

  @override
  F1026MargolusBlockCaHppGasMetadata get metadata => F1026MargolusBlockCaHppGasMetadata.instance;

  @override
  List<F1026MargolusBlockCaHppGasPreset> get presets => F1026MargolusBlockCaHppGasPresets.all;

  @override
  List<F1026MargolusBlockCaHppGasVariant> get variants => F1026MargolusBlockCaHppGasVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
