// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0320_seeds_ca_presets.dart';
import 'f0320_seeds_ca_variants.dart';
import 'f0320_seeds_ca_metadata.dart';

/// Seeds CA — Cellular & Stochastic.
class F0320SeedsCa extends CellularModule {
  F0320SeedsCa()
      : super(
          id: 'f0320_seeds_ca',
          shader: 'shaders/f0320_seeds_ca_gpu.frag',
        );

  @override
  F0320SeedsCaMetadata get metadata => F0320SeedsCaMetadata.instance;

  @override
  List<F0320SeedsCaPreset> get presets => F0320SeedsCaPresets.all;

  @override
  List<F0320SeedsCaVariant> get variants => F0320SeedsCaVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
