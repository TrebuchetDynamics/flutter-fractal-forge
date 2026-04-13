// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0196_period_9_julia_presets.dart';
import 'f0196_period_9_julia_variants.dart';
import 'f0196_period_9_julia_metadata.dart';

/// Period-9 Julia — Escape-Time (Complex Plane).
class F0196Period9Julia extends EscapeTimeModule {
  F0196Period9Julia()
      : super(
          id: 'f0196_period_9_julia',
          shader: 'shaders/f0196_period_9_julia_gpu.frag',
        );

  @override
  F0196Period9JuliaMetadata get metadata => F0196Period9JuliaMetadata.instance;

  @override
  List<F0196Period9JuliaPreset> get presets => F0196Period9JuliaPresets.all;

  @override
  List<F0196Period9JuliaVariant> get variants => F0196Period9JuliaVariants.all;

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
