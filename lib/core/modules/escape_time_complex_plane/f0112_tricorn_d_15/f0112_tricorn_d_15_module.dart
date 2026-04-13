// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0112_tricorn_d_15_presets.dart';
import 'f0112_tricorn_d_15_variants.dart';
import 'f0112_tricorn_d_15_metadata.dart';

/// Tricorn d=15 — Escape-Time (Complex Plane).
class F0112TricornD15 extends EscapeTimeModule {
  F0112TricornD15()
      : super(
          id: 'f0112_tricorn_d_15',
          shader: 'shaders/f0112_tricorn_d_15_gpu.frag',
        );

  @override
  F0112TricornD15Metadata get metadata => F0112TricornD15Metadata.instance;

  @override
  List<F0112TricornD15Preset> get presets => F0112TricornD15Presets.all;

  @override
  List<F0112TricornD15Variant> get variants => F0112TricornD15Variants.all;

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
