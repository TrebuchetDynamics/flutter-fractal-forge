// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0986_gnarl_b1_s1_presets.dart';
import 'f0986_gnarl_b1_s1_variants.dart';
import 'f0986_gnarl_b1_s1_metadata.dart';

/// Gnarl (B1/S1) — Cellular & Stochastic.
class F0986GnarlB1S1 extends CellularModule {
  F0986GnarlB1S1()
      : super(
          id: 'f0986_gnarl_b1_s1',
          shader: 'shaders/f0986_gnarl_b1_s1_gpu.frag',
        );

  @override
  F0986GnarlB1S1Metadata get metadata => F0986GnarlB1S1Metadata.instance;

  @override
  List<F0986GnarlB1S1Preset> get presets => F0986GnarlB1S1Presets.all;

  @override
  List<F0986GnarlB1S1Variant> get variants => F0986GnarlB1S1Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
