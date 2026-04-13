// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0158_period_7_julia_presets.dart';
import 'f0158_period_7_julia_variants.dart';
import 'f0158_period_7_julia_metadata.dart';

/// Period-7 Julia — Escape-Time (Complex Plane).
class F0158Period7Julia extends EscapeTimeModule {
  F0158Period7Julia()
      : super(
          id: 'f0158_period_7_julia',
          shader: 'shaders/f0158_period_7_julia_gpu.frag',
        );

  @override
  F0158Period7JuliaMetadata get metadata => F0158Period7JuliaMetadata.instance;

  @override
  List<F0158Period7JuliaPreset> get presets => F0158Period7JuliaPresets.all;

  @override
  List<F0158Period7JuliaVariant> get variants => F0158Period7JuliaVariants.all;

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
