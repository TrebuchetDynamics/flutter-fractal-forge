// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0180_jumping_jack_julia_presets.dart';
import 'f0180_jumping_jack_julia_variants.dart';
import 'f0180_jumping_jack_julia_metadata.dart';

/// Jumping Jack Julia — Escape-Time (Complex Plane).
class F0180JumpingJackJulia extends EscapeTimeModule {
  F0180JumpingJackJulia()
      : super(
          id: 'f0180_jumping_jack_julia',
          shader: 'shaders/f0180_jumping_jack_julia_gpu.frag',
        );

  @override
  F0180JumpingJackJuliaMetadata get metadata => F0180JumpingJackJuliaMetadata.instance;

  @override
  List<F0180JumpingJackJuliaPreset> get presets => F0180JumpingJackJuliaPresets.all;

  @override
  List<F0180JumpingJackJuliaVariant> get variants => F0180JumpingJackJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
