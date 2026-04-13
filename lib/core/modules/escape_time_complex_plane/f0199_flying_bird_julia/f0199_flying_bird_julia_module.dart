// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0199_flying_bird_julia_presets.dart';
import 'f0199_flying_bird_julia_variants.dart';
import 'f0199_flying_bird_julia_metadata.dart';

/// Flying Bird Julia — Escape-Time (Complex Plane).
class F0199FlyingBirdJulia extends EscapeTimeModule {
  F0199FlyingBirdJulia()
      : super(
          id: 'f0199_flying_bird_julia',
          shader: 'shaders/f0199_flying_bird_julia_gpu.frag',
        );

  @override
  F0199FlyingBirdJuliaMetadata get metadata => F0199FlyingBirdJuliaMetadata.instance;

  @override
  List<F0199FlyingBirdJuliaPreset> get presets => F0199FlyingBirdJuliaPresets.all;

  @override
  List<F0199FlyingBirdJuliaVariant> get variants => F0199FlyingBirdJuliaVariants.all;

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
