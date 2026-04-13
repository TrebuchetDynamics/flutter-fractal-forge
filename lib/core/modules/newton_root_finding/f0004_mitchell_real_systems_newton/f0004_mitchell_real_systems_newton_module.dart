// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0004_mitchell_real_systems_newton_presets.dart';
import 'f0004_mitchell_real_systems_newton_variants.dart';
import 'f0004_mitchell_real_systems_newton_metadata.dart';

/// Mitchell Real-Systems Newton — Newton / Root-Finding.
class F0004MitchellRealSystemsNewton extends EscapeTimeModule {
  F0004MitchellRealSystemsNewton()
      : super(
          id: 'f0004_mitchell_real_systems_newton',
          shader: 'shaders/f0004_mitchell_real_systems_newton_gpu.frag',
        );

  @override
  F0004MitchellRealSystemsNewtonMetadata get metadata => F0004MitchellRealSystemsNewtonMetadata.instance;

  @override
  List<F0004MitchellRealSystemsNewtonPreset> get presets => F0004MitchellRealSystemsNewtonPresets.all;

  @override
  List<F0004MitchellRealSystemsNewtonVariant> get variants => F0004MitchellRealSystemsNewtonVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 2.0;

  @override
  int get defaultIterations => 32;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
