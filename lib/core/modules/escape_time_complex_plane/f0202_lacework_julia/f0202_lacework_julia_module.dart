// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0202_lacework_julia_presets.dart';
import 'f0202_lacework_julia_variants.dart';
import 'f0202_lacework_julia_metadata.dart';

/// Lacework Julia — Escape-Time (Complex Plane).
class F0202LaceworkJulia extends EscapeTimeModule {
  F0202LaceworkJulia()
      : super(
          id: 'f0202_lacework_julia',
          shader: 'shaders/f0202_lacework_julia_gpu.frag',
        );

  @override
  F0202LaceworkJuliaMetadata get metadata => F0202LaceworkJuliaMetadata.instance;

  @override
  List<F0202LaceworkJuliaPreset> get presets => F0202LaceworkJuliaPresets.all;

  @override
  List<F0202LaceworkJuliaVariant> get variants => F0202LaceworkJuliaVariants.all;

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
