// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0003_mitchell_alternating_equations_newton_presets.dart';
import 'f0003_mitchell_alternating_equations_newton_variants.dart';
import 'f0003_mitchell_alternating_equations_newton_metadata.dart';

/// Mitchell Alternating-Equations Newton — Newton / Root-Finding.
class F0003MitchellAlternatingEquationsNewton extends EscapeTimeModule {
  F0003MitchellAlternatingEquationsNewton()
      : super(
          id: 'f0003_mitchell_alternating_equations_newton',
          shader: 'shaders/f0003_mitchell_alternating_equations_newton_gpu.frag',
        );

  @override
  F0003MitchellAlternatingEquationsNewtonMetadata get metadata => F0003MitchellAlternatingEquationsNewtonMetadata.instance;

  @override
  List<F0003MitchellAlternatingEquationsNewtonPreset> get presets => F0003MitchellAlternatingEquationsNewtonPresets.all;

  @override
  List<F0003MitchellAlternatingEquationsNewtonVariant> get variants => F0003MitchellAlternatingEquationsNewtonVariants.all;

  @override
  double get defaultPower => 2.0;

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
