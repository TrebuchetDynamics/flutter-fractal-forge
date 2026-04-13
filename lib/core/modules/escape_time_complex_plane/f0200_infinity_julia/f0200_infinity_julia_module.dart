// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0200_infinity_julia_presets.dart';
import 'f0200_infinity_julia_variants.dart';
import 'f0200_infinity_julia_metadata.dart';

/// Infinity Julia — Escape-Time (Complex Plane).
class F0200InfinityJulia extends EscapeTimeModule {
  F0200InfinityJulia()
      : super(
          id: 'f0200_infinity_julia',
          shader: 'shaders/f0200_infinity_julia_gpu.frag',
        );

  @override
  F0200InfinityJuliaMetadata get metadata => F0200InfinityJuliaMetadata.instance;

  @override
  List<F0200InfinityJuliaPreset> get presets => F0200InfinityJuliaPresets.all;

  @override
  List<F0200InfinityJuliaVariant> get variants => F0200InfinityJuliaVariants.all;

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
