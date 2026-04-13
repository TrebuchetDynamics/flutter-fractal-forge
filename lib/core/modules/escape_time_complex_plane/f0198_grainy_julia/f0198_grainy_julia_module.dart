// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0198_grainy_julia_presets.dart';
import 'f0198_grainy_julia_variants.dart';
import 'f0198_grainy_julia_metadata.dart';

/// Grainy Julia — Escape-Time (Complex Plane).
class F0198GrainyJulia extends EscapeTimeModule {
  F0198GrainyJulia()
      : super(
          id: 'f0198_grainy_julia',
          shader: 'shaders/f0198_grainy_julia_gpu.frag',
        );

  @override
  F0198GrainyJuliaMetadata get metadata => F0198GrainyJuliaMetadata.instance;

  @override
  List<F0198GrainyJuliaPreset> get presets => F0198GrainyJuliaPresets.all;

  @override
  List<F0198GrainyJuliaVariant> get variants => F0198GrainyJuliaVariants.all;

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
