// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0848_koch_snowflake_order_2_presets.dart';
import 'f0848_koch_snowflake_order_2_variants.dart';
import 'f0848_koch_snowflake_order_2_metadata.dart';

/// Koch Snowflake (Order 2) — L-Systems & Space-Filling.
class F0848KochSnowflakeOrder2 extends LSystemModule {
  F0848KochSnowflakeOrder2()
      : super(
          id: 'f0848_koch_snowflake_order_2',
          shader: 'shaders/f0848_koch_snowflake_order_2_gpu.frag',
        );

  @override
  F0848KochSnowflakeOrder2Metadata get metadata => F0848KochSnowflakeOrder2Metadata.instance;

  @override
  List<F0848KochSnowflakeOrder2Preset> get presets => F0848KochSnowflakeOrder2Presets.all;

  @override
  List<F0848KochSnowflakeOrder2Variant> get variants => F0848KochSnowflakeOrder2Variants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
