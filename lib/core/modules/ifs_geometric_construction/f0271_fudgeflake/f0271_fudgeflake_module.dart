// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0271_fudgeflake_presets.dart';
import 'f0271_fudgeflake_variants.dart';
import 'f0271_fudgeflake_metadata.dart';

/// Fudgeflake — IFS & Geometric Construction.
class F0271Fudgeflake extends IFSModule {
  F0271Fudgeflake()
      : super(
          id: 'f0271_fudgeflake',
          shader: 'shaders/f0271_fudgeflake_gpu.frag',
        );

  @override
  F0271FudgeflakeMetadata get metadata => F0271FudgeflakeMetadata.instance;

  @override
  List<F0271FudgeflakePreset> get presets => F0271FudgeflakePresets.all;

  @override
  List<F0271FudgeflakeVariant> get variants => F0271FudgeflakeVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
