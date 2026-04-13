// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0005_mitchell_matrix_newton_sand_storm_presets.dart';
import 'f0005_mitchell_matrix_newton_sand_storm_variants.dart';
import 'f0005_mitchell_matrix_newton_sand_storm_metadata.dart';

/// Mitchell Matrix Newton (Sand Storm) — Newton / Root-Finding.
class F0005MitchellMatrixNewtonSandStorm extends EscapeTimeModule {
  F0005MitchellMatrixNewtonSandStorm()
      : super(
          id: 'f0005_mitchell_matrix_newton_sand_storm',
          shader: 'shaders/f0005_mitchell_matrix_newton_sand_storm_gpu.frag',
        );

  @override
  F0005MitchellMatrixNewtonSandStormMetadata get metadata => F0005MitchellMatrixNewtonSandStormMetadata.instance;

  @override
  List<F0005MitchellMatrixNewtonSandStormPreset> get presets => F0005MitchellMatrixNewtonSandStormPresets.all;

  @override
  List<F0005MitchellMatrixNewtonSandStormVariant> get variants => F0005MitchellMatrixNewtonSandStormVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 2.0;

  @override
  int get defaultIterations => 64;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
