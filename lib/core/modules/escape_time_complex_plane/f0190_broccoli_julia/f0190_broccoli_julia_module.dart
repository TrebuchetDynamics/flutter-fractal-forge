// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0190_broccoli_julia_presets.dart';
import 'f0190_broccoli_julia_variants.dart';
import 'f0190_broccoli_julia_metadata.dart';

/// Broccoli Julia — Escape-Time (Complex Plane).
class F0190BroccoliJulia extends EscapeTimeModule {
  F0190BroccoliJulia()
      : super(
          id: 'f0190_broccoli_julia',
          shader: 'shaders/f0190_broccoli_julia_gpu.frag',
        );

  @override
  F0190BroccoliJuliaMetadata get metadata => F0190BroccoliJuliaMetadata.instance;

  @override
  List<F0190BroccoliJuliaPreset> get presets => F0190BroccoliJuliaPresets.all;

  @override
  List<F0190BroccoliJuliaVariant> get variants => F0190BroccoliJuliaVariants.all;

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
