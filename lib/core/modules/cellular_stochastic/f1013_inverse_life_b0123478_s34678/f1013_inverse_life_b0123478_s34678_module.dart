// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1013_inverse_life_b0123478_s34678_presets.dart';
import 'f1013_inverse_life_b0123478_s34678_variants.dart';
import 'f1013_inverse_life_b0123478_s34678_metadata.dart';

/// Inverse Life (B0123478/S34678) — Cellular & Stochastic.
class F1013InverseLifeB0123478S34678 extends CellularModule {
  F1013InverseLifeB0123478S34678()
      : super(
          id: 'f1013_inverse_life_b0123478_s34678',
          shader: 'shaders/f1013_inverse_life_b0123478_s34678_gpu.frag',
        );

  @override
  F1013InverseLifeB0123478S34678Metadata get metadata => F1013InverseLifeB0123478S34678Metadata.instance;

  @override
  List<F1013InverseLifeB0123478S34678Preset> get presets => F1013InverseLifeB0123478S34678Presets.all;

  @override
  List<F1013InverseLifeB0123478S34678Variant> get variants => F1013InverseLifeB0123478S34678Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
