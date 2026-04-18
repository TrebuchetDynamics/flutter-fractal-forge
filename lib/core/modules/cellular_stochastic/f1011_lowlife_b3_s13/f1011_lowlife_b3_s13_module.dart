// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1011_lowlife_b3_s13_presets.dart';
import 'f1011_lowlife_b3_s13_variants.dart';
import 'f1011_lowlife_b3_s13_metadata.dart';

/// LowLife (B3/S13) — Cellular & Stochastic.
class F1011LowlifeB3S13 extends CellularModule {
  F1011LowlifeB3S13()
      : super(
          id: 'f1011_lowlife_b3_s13',
          shader: 'shaders/f1011_lowlife_b3_s13_gpu.frag',
        );

  @override
  F1011LowlifeB3S13Metadata get metadata => F1011LowlifeB3S13Metadata.instance;

  @override
  List<F1011LowlifeB3S13Preset> get presets => F1011LowlifeB3S13Presets.all;

  @override
  List<F1011LowlifeB3S13Variant> get variants => F1011LowlifeB3S13Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
