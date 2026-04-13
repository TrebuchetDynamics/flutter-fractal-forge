// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0108_tricorn_d_11_presets.dart';
import 'f0108_tricorn_d_11_variants.dart';
import 'f0108_tricorn_d_11_metadata.dart';

/// Tricorn d=11 — Escape-Time (Complex Plane).
class F0108TricornD11 extends EscapeTimeModule {
  F0108TricornD11()
      : super(
          id: 'f0108_tricorn_d_11',
          shader: 'shaders/f0108_tricorn_d_11_gpu.frag',
        );

  @override
  F0108TricornD11Metadata get metadata => F0108TricornD11Metadata.instance;

  @override
  List<F0108TricornD11Preset> get presets => F0108TricornD11Presets.all;

  @override
  List<F0108TricornD11Variant> get variants => F0108TricornD11Variants.all;

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
