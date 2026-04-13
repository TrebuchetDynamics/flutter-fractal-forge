// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0334_belousov_zhabotinsky_ca_presets.dart';
import 'f0334_belousov_zhabotinsky_ca_variants.dart';
import 'f0334_belousov_zhabotinsky_ca_metadata.dart';

/// Belousov-Zhabotinsky CA — Cellular & Stochastic.
class F0334BelousovZhabotinskyCa extends CellularModule {
  F0334BelousovZhabotinskyCa()
      : super(
          id: 'f0334_belousov_zhabotinsky_ca',
          shader: 'shaders/f0334_belousov_zhabotinsky_ca_gpu.frag',
        );

  @override
  F0334BelousovZhabotinskyCaMetadata get metadata => F0334BelousovZhabotinskyCaMetadata.instance;

  @override
  List<F0334BelousovZhabotinskyCaPreset> get presets => F0334BelousovZhabotinskyCaPresets.all;

  @override
  List<F0334BelousovZhabotinskyCaVariant> get variants => F0334BelousovZhabotinskyCaVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
