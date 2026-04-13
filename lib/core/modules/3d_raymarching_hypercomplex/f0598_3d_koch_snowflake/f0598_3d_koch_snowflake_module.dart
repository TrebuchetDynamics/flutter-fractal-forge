// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0598_3d_koch_snowflake_presets.dart';
import 'f0598_3d_koch_snowflake_variants.dart';
import 'f0598_3d_koch_snowflake_metadata.dart';

/// 3D Koch Snowflake — 3D Raymarching & Hypercomplex.
class F05983dKochSnowflake extends Raymarched3DModule {
  F05983dKochSnowflake()
      : super(
          id: 'f0598_3d_koch_snowflake',
          shader: 'shaders/f0598_3d_koch_snowflake_gpu.frag',
        );

  @override
  F05983dKochSnowflakeMetadata get metadata => F05983dKochSnowflakeMetadata.instance;

  @override
  List<F05983dKochSnowflakePreset> get presets => F05983dKochSnowflakePresets.all;

  @override
  List<F05983dKochSnowflakeVariant> get variants => F05983dKochSnowflakeVariants.all;

  @override
  double get defaultPower => 8.0;

  @override
  int get defaultSteps => 200;

  @override
  int get defaultIterations => 20;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setInt('steps', defaultSteps);
    p.setInt('iterations', defaultIterations);
  }
}
