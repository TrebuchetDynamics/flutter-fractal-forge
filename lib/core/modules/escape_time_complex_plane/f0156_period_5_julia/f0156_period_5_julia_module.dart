// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0156_period_5_julia_presets.dart';
import 'f0156_period_5_julia_variants.dart';
import 'f0156_period_5_julia_metadata.dart';

/// Period-5 Julia — Escape-Time (Complex Plane).
class F0156Period5Julia extends EscapeTimeModule {
  F0156Period5Julia()
      : super(
          id: 'f0156_period_5_julia',
          shader: 'shaders/f0156_period_5_julia_gpu.frag',
        );

  @override
  F0156Period5JuliaMetadata get metadata => F0156Period5JuliaMetadata.instance;

  @override
  List<F0156Period5JuliaPreset> get presets => F0156Period5JuliaPresets.all;

  @override
  List<F0156Period5JuliaVariant> get variants => F0156Period5JuliaVariants.all;

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
