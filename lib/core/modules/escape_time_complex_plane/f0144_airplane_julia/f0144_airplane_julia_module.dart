// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0144_airplane_julia_presets.dart';
import 'f0144_airplane_julia_variants.dart';
import 'f0144_airplane_julia_metadata.dart';

/// Airplane Julia — Escape-Time (Complex Plane).
class F0144AirplaneJulia extends EscapeTimeModule {
  F0144AirplaneJulia()
      : super(
          id: 'f0144_airplane_julia',
          shader: 'shaders/f0144_airplane_julia_gpu.frag',
        );

  @override
  F0144AirplaneJuliaMetadata get metadata => F0144AirplaneJuliaMetadata.instance;

  @override
  List<F0144AirplaneJuliaPreset> get presets => F0144AirplaneJuliaPresets.all;

  @override
  List<F0144AirplaneJuliaVariant> get variants => F0144AirplaneJuliaVariants.all;

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
