// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0538_newton_sin_presets.dart';
import 'f0538_newton_sin_variants.dart';
import 'f0538_newton_sin_metadata.dart';

/// Newton-sin — Escape-Time (Complex Plane).
class F0538NewtonSin extends EscapeTimeModule {
  F0538NewtonSin()
      : super(
          id: 'f0538_newton_sin',
          shader: 'shaders/f0538_newton_sin_gpu.frag',
        );

  @override
  F0538NewtonSinMetadata get metadata => F0538NewtonSinMetadata.instance;

  @override
  List<F0538NewtonSinPreset> get presets => F0538NewtonSinPresets.all;

  @override
  List<F0538NewtonSinVariant> get variants => F0538NewtonSinVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
