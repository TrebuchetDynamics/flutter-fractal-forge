// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0175_near_elephant_julia_presets.dart';
import 'f0175_near_elephant_julia_variants.dart';
import 'f0175_near_elephant_julia_metadata.dart';

/// Near-Elephant Julia — Escape-Time (Complex Plane).
class F0175NearElephantJulia extends EscapeTimeModule {
  F0175NearElephantJulia()
      : super(
          id: 'f0175_near_elephant_julia',
          shader: 'shaders/f0175_near_elephant_julia_gpu.frag',
        );

  @override
  F0175NearElephantJuliaMetadata get metadata => F0175NearElephantJuliaMetadata.instance;

  @override
  List<F0175NearElephantJuliaPreset> get presets => F0175NearElephantJuliaPresets.all;

  @override
  List<F0175NearElephantJuliaVariant> get variants => F0175NearElephantJuliaVariants.all;

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
