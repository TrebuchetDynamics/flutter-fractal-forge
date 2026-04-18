// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1000_snowflakes_b1_s12345678_presets.dart';
import 'f1000_snowflakes_b1_s12345678_variants.dart';
import 'f1000_snowflakes_b1_s12345678_metadata.dart';

/// Snowflakes (B1/S12345678) — Cellular & Stochastic.
class F1000SnowflakesB1S12345678 extends CellularModule {
  F1000SnowflakesB1S12345678()
      : super(
          id: 'f1000_snowflakes_b1_s12345678',
          shader: 'shaders/f1000_snowflakes_b1_s12345678_gpu.frag',
        );

  @override
  F1000SnowflakesB1S12345678Metadata get metadata => F1000SnowflakesB1S12345678Metadata.instance;

  @override
  List<F1000SnowflakesB1S12345678Preset> get presets => F1000SnowflakesB1S12345678Presets.all;

  @override
  List<F1000SnowflakesB1S12345678Variant> get variants => F1000SnowflakesB1S12345678Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
