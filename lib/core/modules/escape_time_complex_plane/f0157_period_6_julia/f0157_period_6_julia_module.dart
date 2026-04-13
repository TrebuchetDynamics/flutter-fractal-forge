// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0157_period_6_julia_presets.dart';
import 'f0157_period_6_julia_variants.dart';
import 'f0157_period_6_julia_metadata.dart';

/// Period-6 Julia — Escape-Time (Complex Plane).
class F0157Period6Julia extends EscapeTimeModule {
  F0157Period6Julia()
      : super(
          id: 'f0157_period_6_julia',
          shader: 'shaders/f0157_period_6_julia_gpu.frag',
        );

  @override
  F0157Period6JuliaMetadata get metadata => F0157Period6JuliaMetadata.instance;

  @override
  List<F0157Period6JuliaPreset> get presets => F0157Period6JuliaPresets.all;

  @override
  List<F0157Period6JuliaVariant> get variants => F0157Period6JuliaVariants.all;

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
