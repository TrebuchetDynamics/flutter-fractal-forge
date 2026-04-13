// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0152_galaxy_julia_presets.dart';
import 'f0152_galaxy_julia_variants.dart';
import 'f0152_galaxy_julia_metadata.dart';

/// Galaxy Julia — Escape-Time (Complex Plane).
class F0152GalaxyJulia extends EscapeTimeModule {
  F0152GalaxyJulia()
      : super(
          id: 'f0152_galaxy_julia',
          shader: 'shaders/f0152_galaxy_julia_gpu.frag',
        );

  @override
  F0152GalaxyJuliaMetadata get metadata => F0152GalaxyJuliaMetadata.instance;

  @override
  List<F0152GalaxyJuliaPreset> get presets => F0152GalaxyJuliaPresets.all;

  @override
  List<F0152GalaxyJuliaVariant> get variants => F0152GalaxyJuliaVariants.all;

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
