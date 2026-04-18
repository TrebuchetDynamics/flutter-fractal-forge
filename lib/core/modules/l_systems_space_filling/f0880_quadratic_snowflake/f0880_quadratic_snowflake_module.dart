// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0880_quadratic_snowflake_presets.dart';
import 'f0880_quadratic_snowflake_variants.dart';
import 'f0880_quadratic_snowflake_metadata.dart';

/// Quadratic Snowflake — L-Systems & Space-Filling.
class F0880QuadraticSnowflake extends LSystemModule {
  F0880QuadraticSnowflake()
      : super(
          id: 'f0880_quadratic_snowflake',
          shader: 'shaders/f0880_quadratic_snowflake_gpu.frag',
        );

  @override
  F0880QuadraticSnowflakeMetadata get metadata => F0880QuadraticSnowflakeMetadata.instance;

  @override
  List<F0880QuadraticSnowflakePreset> get presets => F0880QuadraticSnowflakePresets.all;

  @override
  List<F0880QuadraticSnowflakeVariant> get variants => F0880QuadraticSnowflakeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
