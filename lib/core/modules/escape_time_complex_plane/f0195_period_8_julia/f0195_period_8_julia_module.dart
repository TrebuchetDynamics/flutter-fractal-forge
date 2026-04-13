// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0195_period_8_julia_presets.dart';
import 'f0195_period_8_julia_variants.dart';
import 'f0195_period_8_julia_metadata.dart';

/// Period-8 Julia — Escape-Time (Complex Plane).
class F0195Period8Julia extends EscapeTimeModule {
  F0195Period8Julia()
      : super(
          id: 'f0195_period_8_julia',
          shader: 'shaders/f0195_period_8_julia_gpu.frag',
        );

  @override
  F0195Period8JuliaMetadata get metadata => F0195Period8JuliaMetadata.instance;

  @override
  List<F0195Period8JuliaPreset> get presets => F0195Period8JuliaPresets.all;

  @override
  List<F0195Period8JuliaVariant> get variants => F0195Period8JuliaVariants.all;

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
