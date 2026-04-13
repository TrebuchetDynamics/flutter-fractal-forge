// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0182_hyperbolic_julia_presets.dart';
import 'f0182_hyperbolic_julia_variants.dart';
import 'f0182_hyperbolic_julia_metadata.dart';

/// Hyperbolic Julia — Escape-Time (Complex Plane).
class F0182HyperbolicJulia extends EscapeTimeModule {
  F0182HyperbolicJulia()
      : super(
          id: 'f0182_hyperbolic_julia',
          shader: 'shaders/f0182_hyperbolic_julia_gpu.frag',
        );

  @override
  F0182HyperbolicJuliaMetadata get metadata => F0182HyperbolicJuliaMetadata.instance;

  @override
  List<F0182HyperbolicJuliaPreset> get presets => F0182HyperbolicJuliaPresets.all;

  @override
  List<F0182HyperbolicJuliaVariant> get variants => F0182HyperbolicJuliaVariants.all;

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
