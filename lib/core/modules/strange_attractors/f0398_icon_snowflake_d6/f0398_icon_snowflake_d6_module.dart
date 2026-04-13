// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0398_icon_snowflake_d6_presets.dart';
import 'f0398_icon_snowflake_d6_variants.dart';
import 'f0398_icon_snowflake_d6_metadata.dart';

/// Icon — Snowflake D6 — Strange Attractors.
class F0398IconSnowflakeD6 extends AttractorModule {
  F0398IconSnowflakeD6()
      : super(
          id: 'f0398_icon_snowflake_d6',
          shader: 'shaders/f0398_icon_snowflake_d6_gpu.frag',
        );

  @override
  F0398IconSnowflakeD6Metadata get metadata => F0398IconSnowflakeD6Metadata.instance;

  @override
  List<F0398IconSnowflakeD6Preset> get presets => F0398IconSnowflakeD6Presets.all;

  @override
  List<F0398IconSnowflakeD6Variant> get variants => F0398IconSnowflakeD6Variants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
