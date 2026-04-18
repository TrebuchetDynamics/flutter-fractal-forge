// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0994_iceballs_b25678_s5678_presets.dart';
import 'f0994_iceballs_b25678_s5678_variants.dart';
import 'f0994_iceballs_b25678_s5678_metadata.dart';

/// Iceballs (B25678/S5678) — Cellular & Stochastic.
class F0994IceballsB25678S5678 extends CellularModule {
  F0994IceballsB25678S5678()
      : super(
          id: 'f0994_iceballs_b25678_s5678',
          shader: 'shaders/f0994_iceballs_b25678_s5678_gpu.frag',
        );

  @override
  F0994IceballsB25678S5678Metadata get metadata => F0994IceballsB25678S5678Metadata.instance;

  @override
  List<F0994IceballsB25678S5678Preset> get presets => F0994IceballsB25678S5678Presets.all;

  @override
  List<F0994IceballsB25678S5678Variant> get variants => F0994IceballsB25678S5678Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
