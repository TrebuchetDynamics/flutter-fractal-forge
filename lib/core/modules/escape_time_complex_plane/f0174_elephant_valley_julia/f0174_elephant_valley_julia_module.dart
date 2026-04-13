// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0174_elephant_valley_julia_presets.dart';
import 'f0174_elephant_valley_julia_variants.dart';
import 'f0174_elephant_valley_julia_metadata.dart';

/// Elephant Valley Julia — Escape-Time (Complex Plane).
class F0174ElephantValleyJulia extends EscapeTimeModule {
  F0174ElephantValleyJulia()
      : super(
          id: 'f0174_elephant_valley_julia',
          shader: 'shaders/f0174_elephant_valley_julia_gpu.frag',
        );

  @override
  F0174ElephantValleyJuliaMetadata get metadata => F0174ElephantValleyJuliaMetadata.instance;

  @override
  List<F0174ElephantValleyJuliaPreset> get presets => F0174ElephantValleyJuliaPresets.all;

  @override
  List<F0174ElephantValleyJuliaVariant> get variants => F0174ElephantValleyJuliaVariants.all;

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
