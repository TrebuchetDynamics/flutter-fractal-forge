// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0161_swirl_julia_presets.dart';
import 'f0161_swirl_julia_variants.dart';
import 'f0161_swirl_julia_metadata.dart';

/// Swirl Julia — Escape-Time (Complex Plane).
class F0161SwirlJulia extends EscapeTimeModule {
  F0161SwirlJulia()
      : super(
          id: 'f0161_swirl_julia',
          shader: 'shaders/f0161_swirl_julia_gpu.frag',
        );

  @override
  F0161SwirlJuliaMetadata get metadata => F0161SwirlJuliaMetadata.instance;

  @override
  List<F0161SwirlJuliaPreset> get presets => F0161SwirlJuliaPresets.all;

  @override
  List<F0161SwirlJuliaVariant> get variants => F0161SwirlJuliaVariants.all;

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
