// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0404_icon_snowflake_d12_presets.dart';
import 'f0404_icon_snowflake_d12_variants.dart';
import 'f0404_icon_snowflake_d12_metadata.dart';

/// Icon — Snowflake D12 — Strange Attractors.
class F0404IconSnowflakeD12 extends AttractorModule {
  F0404IconSnowflakeD12()
      : super(
          id: 'f0404_icon_snowflake_d12',
          shader: 'shaders/f0404_icon_snowflake_d12_gpu.frag',
        );

  @override
  F0404IconSnowflakeD12Metadata get metadata => F0404IconSnowflakeD12Metadata.instance;

  @override
  List<F0404IconSnowflakeD12Preset> get presets => F0404IconSnowflakeD12Presets.all;

  @override
  List<F0404IconSnowflakeD12Variant> get variants => F0404IconSnowflakeD12Variants.all;

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
