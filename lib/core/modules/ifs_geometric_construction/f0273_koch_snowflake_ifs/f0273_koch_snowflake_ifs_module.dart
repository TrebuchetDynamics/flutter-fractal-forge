// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0273_koch_snowflake_ifs_presets.dart';
import 'f0273_koch_snowflake_ifs_variants.dart';
import 'f0273_koch_snowflake_ifs_metadata.dart';

/// Koch Snowflake IFS — IFS & Geometric Construction.
class F0273KochSnowflakeIfs extends IFSModule {
  F0273KochSnowflakeIfs()
      : super(
          id: 'f0273_koch_snowflake_ifs',
          shader: 'shaders/f0273_koch_snowflake_ifs_gpu.frag',
        );

  @override
  F0273KochSnowflakeIfsMetadata get metadata => F0273KochSnowflakeIfsMetadata.instance;

  @override
  List<F0273KochSnowflakeIfsPreset> get presets => F0273KochSnowflakeIfsPresets.all;

  @override
  List<F0273KochSnowflakeIfsVariant> get variants => F0273KochSnowflakeIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
