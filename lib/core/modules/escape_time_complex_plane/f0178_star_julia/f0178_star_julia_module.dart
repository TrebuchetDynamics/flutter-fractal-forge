// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0178_star_julia_presets.dart';
import 'f0178_star_julia_variants.dart';
import 'f0178_star_julia_metadata.dart';

/// Star Julia — Escape-Time (Complex Plane).
class F0178StarJulia extends EscapeTimeModule {
  F0178StarJulia()
      : super(
          id: 'f0178_star_julia',
          shader: 'shaders/f0178_star_julia_gpu.frag',
        );

  @override
  F0178StarJuliaMetadata get metadata => F0178StarJuliaMetadata.instance;

  @override
  List<F0178StarJuliaPreset> get presets => F0178StarJuliaPresets.all;

  @override
  List<F0178StarJuliaVariant> get variants => F0178StarJuliaVariants.all;

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
