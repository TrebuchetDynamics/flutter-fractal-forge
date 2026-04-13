// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0259_snowflake_of_snowflakes_presets.dart';
import 'f0259_snowflake_of_snowflakes_variants.dart';
import 'f0259_snowflake_of_snowflakes_metadata.dart';

/// Snowflake of Snowflakes — L-Systems & Space-Filling.
class F0259SnowflakeOfSnowflakes extends LSystemModule {
  F0259SnowflakeOfSnowflakes()
      : super(
          id: 'f0259_snowflake_of_snowflakes',
          shader: 'shaders/f0259_snowflake_of_snowflakes_gpu.frag',
        );

  @override
  F0259SnowflakeOfSnowflakesMetadata get metadata => F0259SnowflakeOfSnowflakesMetadata.instance;

  @override
  List<F0259SnowflakeOfSnowflakesPreset> get presets => F0259SnowflakeOfSnowflakesPresets.all;

  @override
  List<F0259SnowflakeOfSnowflakesVariant> get variants => F0259SnowflakeOfSnowflakesVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
