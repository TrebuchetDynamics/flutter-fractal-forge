// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0191_spring_julia_presets.dart';
import 'f0191_spring_julia_variants.dart';
import 'f0191_spring_julia_metadata.dart';

/// Spring Julia — Escape-Time (Complex Plane).
class F0191SpringJulia extends EscapeTimeModule {
  F0191SpringJulia()
      : super(
          id: 'f0191_spring_julia',
          shader: 'shaders/f0191_spring_julia_gpu.frag',
        );

  @override
  F0191SpringJuliaMetadata get metadata => F0191SpringJuliaMetadata.instance;

  @override
  List<F0191SpringJuliaPreset> get presets => F0191SpringJuliaPresets.all;

  @override
  List<F0191SpringJuliaVariant> get variants => F0191SpringJuliaVariants.all;

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
