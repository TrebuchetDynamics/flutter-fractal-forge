// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0849_koch_anti_snowflake_presets.dart';
import 'f0849_koch_anti_snowflake_variants.dart';
import 'f0849_koch_anti_snowflake_metadata.dart';

/// Koch Anti-Snowflake — L-Systems & Space-Filling.
class F0849KochAntiSnowflake extends LSystemModule {
  F0849KochAntiSnowflake()
      : super(
          id: 'f0849_koch_anti_snowflake',
          shader: 'shaders/f0849_koch_anti_snowflake_gpu.frag',
        );

  @override
  F0849KochAntiSnowflakeMetadata get metadata => F0849KochAntiSnowflakeMetadata.instance;

  @override
  List<F0849KochAntiSnowflakePreset> get presets => F0849KochAntiSnowflakePresets.all;

  @override
  List<F0849KochAntiSnowflakeVariant> get variants => F0849KochAntiSnowflakeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
