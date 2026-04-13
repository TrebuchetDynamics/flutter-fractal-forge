// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0177_mink_julia_presets.dart';
import 'f0177_mink_julia_variants.dart';
import 'f0177_mink_julia_metadata.dart';

/// Mink Julia — Escape-Time (Complex Plane).
class F0177MinkJulia extends EscapeTimeModule {
  F0177MinkJulia()
      : super(
          id: 'f0177_mink_julia',
          shader: 'shaders/f0177_mink_julia_gpu.frag',
        );

  @override
  F0177MinkJuliaMetadata get metadata => F0177MinkJuliaMetadata.instance;

  @override
  List<F0177MinkJuliaPreset> get presets => F0177MinkJuliaPresets.all;

  @override
  List<F0177MinkJuliaVariant> get variants => F0177MinkJuliaVariants.all;

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
