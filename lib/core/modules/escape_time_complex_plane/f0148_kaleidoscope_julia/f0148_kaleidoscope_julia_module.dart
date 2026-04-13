// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0148_kaleidoscope_julia_presets.dart';
import 'f0148_kaleidoscope_julia_variants.dart';
import 'f0148_kaleidoscope_julia_metadata.dart';

/// Kaleidoscope Julia — Escape-Time (Complex Plane).
class F0148KaleidoscopeJulia extends EscapeTimeModule {
  F0148KaleidoscopeJulia()
      : super(
          id: 'f0148_kaleidoscope_julia',
          shader: 'shaders/f0148_kaleidoscope_julia_gpu.frag',
        );

  @override
  F0148KaleidoscopeJuliaMetadata get metadata => F0148KaleidoscopeJuliaMetadata.instance;

  @override
  List<F0148KaleidoscopeJuliaPreset> get presets => F0148KaleidoscopeJuliaPresets.all;

  @override
  List<F0148KaleidoscopeJuliaVariant> get variants => F0148KaleidoscopeJuliaVariants.all;

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
