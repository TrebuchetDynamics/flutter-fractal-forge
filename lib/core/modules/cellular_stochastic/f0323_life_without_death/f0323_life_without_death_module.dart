// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0323_life_without_death_presets.dart';
import 'f0323_life_without_death_variants.dart';
import 'f0323_life_without_death_metadata.dart';

/// Life without Death — Cellular & Stochastic.
class F0323LifeWithoutDeath extends CellularModule {
  F0323LifeWithoutDeath()
      : super(
          id: 'f0323_life_without_death',
          shader: 'shaders/f0323_life_without_death_gpu.frag',
        );

  @override
  F0323LifeWithoutDeathMetadata get metadata => F0323LifeWithoutDeathMetadata.instance;

  @override
  List<F0323LifeWithoutDeathPreset> get presets => F0323LifeWithoutDeathPresets.all;

  @override
  List<F0323LifeWithoutDeathVariant> get variants => F0323LifeWithoutDeathVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
