// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1009_eightlife_b3_s238_presets.dart';
import 'f1009_eightlife_b3_s238_variants.dart';
import 'f1009_eightlife_b3_s238_metadata.dart';

/// EightLife (B3/S238) — Cellular & Stochastic.
class F1009EightlifeB3S238 extends CellularModule {
  F1009EightlifeB3S238()
      : super(
          id: 'f1009_eightlife_b3_s238',
          shader: 'shaders/f1009_eightlife_b3_s238_gpu.frag',
        );

  @override
  F1009EightlifeB3S238Metadata get metadata => F1009EightlifeB3S238Metadata.instance;

  @override
  List<F1009EightlifeB3S238Preset> get presets => F1009EightlifeB3S238Presets.all;

  @override
  List<F1009EightlifeB3S238Variant> get variants => F1009EightlifeB3S238Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
