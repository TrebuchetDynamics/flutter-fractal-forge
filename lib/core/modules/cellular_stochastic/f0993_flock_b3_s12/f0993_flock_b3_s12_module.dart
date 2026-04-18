// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0993_flock_b3_s12_presets.dart';
import 'f0993_flock_b3_s12_variants.dart';
import 'f0993_flock_b3_s12_metadata.dart';

/// Flock (B3/S12) — Cellular & Stochastic.
class F0993FlockB3S12 extends CellularModule {
  F0993FlockB3S12()
      : super(
          id: 'f0993_flock_b3_s12',
          shader: 'shaders/f0993_flock_b3_s12_gpu.frag',
        );

  @override
  F0993FlockB3S12Metadata get metadata => F0993FlockB3S12Metadata.instance;

  @override
  List<F0993FlockB3S12Preset> get presets => F0993FlockB3S12Presets.all;

  @override
  List<F0993FlockB3S12Variant> get variants => F0993FlockB3S12Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
