// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0001_mitchell_adjusted_newton_presets.dart';
import 'f0001_mitchell_adjusted_newton_variants.dart';
import 'f0001_mitchell_adjusted_newton_metadata.dart';

/// Mitchell Adjusted Newton — Newton / Root-Finding.
class F0001MitchellAdjustedNewton extends EscapeTimeModule {
  F0001MitchellAdjustedNewton()
      : super(
          id: 'f0001_mitchell_adjusted_newton',
          shader: 'shaders/f0001_mitchell_adjusted_newton_gpu.frag',
        );

  @override
  F0001MitchellAdjustedNewtonMetadata get metadata => F0001MitchellAdjustedNewtonMetadata.instance;

  @override
  List<F0001MitchellAdjustedNewtonPreset> get presets => F0001MitchellAdjustedNewtonPresets.all;

  @override
  List<F0001MitchellAdjustedNewtonVariant> get variants => F0001MitchellAdjustedNewtonVariants.all;

  @override
  double get defaultPower => 4.0;

  @override
  double get defaultBailout => 0.001;

  @override
  int get defaultIterations => 64;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
