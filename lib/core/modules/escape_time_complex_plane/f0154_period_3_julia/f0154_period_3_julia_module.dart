// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0154_period_3_julia_presets.dart';
import 'f0154_period_3_julia_variants.dart';
import 'f0154_period_3_julia_metadata.dart';

/// Period-3 Julia — Escape-Time (Complex Plane).
class F0154Period3Julia extends EscapeTimeModule {
  F0154Period3Julia()
      : super(
          id: 'f0154_period_3_julia',
          shader: 'shaders/f0154_period_3_julia_gpu.frag',
        );

  @override
  F0154Period3JuliaMetadata get metadata => F0154Period3JuliaMetadata.instance;

  @override
  List<F0154Period3JuliaPreset> get presets => F0154Period3JuliaPresets.all;

  @override
  List<F0154Period3JuliaVariant> get variants => F0154Period3JuliaVariants.all;

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
