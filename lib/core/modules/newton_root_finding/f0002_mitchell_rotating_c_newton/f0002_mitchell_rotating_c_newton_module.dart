// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0002_mitchell_rotating_c_newton_presets.dart';
import 'f0002_mitchell_rotating_c_newton_variants.dart';
import 'f0002_mitchell_rotating_c_newton_metadata.dart';

/// Mitchell Rotating-C Newton — Newton / Root-Finding.
class F0002MitchellRotatingCNewton extends EscapeTimeModule {
  F0002MitchellRotatingCNewton()
      : super(
          id: 'f0002_mitchell_rotating_c_newton',
          shader: 'shaders/f0002_mitchell_rotating_c_newton_gpu.frag',
        );

  @override
  F0002MitchellRotatingCNewtonMetadata get metadata => F0002MitchellRotatingCNewtonMetadata.instance;

  @override
  List<F0002MitchellRotatingCNewtonPreset> get presets => F0002MitchellRotatingCNewtonPresets.all;

  @override
  List<F0002MitchellRotatingCNewtonVariant> get variants => F0002MitchellRotatingCNewtonVariants.all;

  @override
  double get defaultPower => 3.0;

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
