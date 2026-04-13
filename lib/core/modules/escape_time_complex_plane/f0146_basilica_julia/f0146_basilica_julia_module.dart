// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0146_basilica_julia_presets.dart';
import 'f0146_basilica_julia_variants.dart';
import 'f0146_basilica_julia_metadata.dart';

/// Basilica Julia — Escape-Time (Complex Plane).
class F0146BasilicaJulia extends EscapeTimeModule {
  F0146BasilicaJulia()
      : super(
          id: 'f0146_basilica_julia',
          shader: 'shaders/f0146_basilica_julia_gpu.frag',
        );

  @override
  F0146BasilicaJuliaMetadata get metadata => F0146BasilicaJuliaMetadata.instance;

  @override
  List<F0146BasilicaJuliaPreset> get presets => F0146BasilicaJuliaPresets.all;

  @override
  List<F0146BasilicaJuliaVariant> get variants => F0146BasilicaJuliaVariants.all;

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
