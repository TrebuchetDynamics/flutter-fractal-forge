// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0155_period_4_julia_presets.dart';
import 'f0155_period_4_julia_variants.dart';
import 'f0155_period_4_julia_metadata.dart';

/// Period-4 Julia — Escape-Time (Complex Plane).
class F0155Period4Julia extends EscapeTimeModule {
  F0155Period4Julia()
      : super(
          id: 'f0155_period_4_julia',
          shader: 'shaders/f0155_period_4_julia_gpu.frag',
        );

  @override
  F0155Period4JuliaMetadata get metadata => F0155Period4JuliaMetadata.instance;

  @override
  List<F0155Period4JuliaPreset> get presets => F0155Period4JuliaPresets.all;

  @override
  List<F0155Period4JuliaVariant> get variants => F0155Period4JuliaVariants.all;

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
