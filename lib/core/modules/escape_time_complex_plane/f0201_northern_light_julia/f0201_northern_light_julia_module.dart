// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0201_northern_light_julia_presets.dart';
import 'f0201_northern_light_julia_variants.dart';
import 'f0201_northern_light_julia_metadata.dart';

/// Northern Light Julia — Escape-Time (Complex Plane).
class F0201NorthernLightJulia extends EscapeTimeModule {
  F0201NorthernLightJulia()
      : super(
          id: 'f0201_northern_light_julia',
          shader: 'shaders/f0201_northern_light_julia_gpu.frag',
        );

  @override
  F0201NorthernLightJuliaMetadata get metadata => F0201NorthernLightJuliaMetadata.instance;

  @override
  List<F0201NorthernLightJuliaPreset> get presets => F0201NorthernLightJuliaPresets.all;

  @override
  List<F0201NorthernLightJuliaVariant> get variants => F0201NorthernLightJuliaVariants.all;

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
