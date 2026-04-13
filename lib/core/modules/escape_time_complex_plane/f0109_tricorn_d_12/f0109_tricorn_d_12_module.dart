// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0109_tricorn_d_12_presets.dart';
import 'f0109_tricorn_d_12_variants.dart';
import 'f0109_tricorn_d_12_metadata.dart';

/// Tricorn d=12 — Escape-Time (Complex Plane).
class F0109TricornD12 extends EscapeTimeModule {
  F0109TricornD12()
      : super(
          id: 'f0109_tricorn_d_12',
          shader: 'shaders/f0109_tricorn_d_12_gpu.frag',
        );

  @override
  F0109TricornD12Metadata get metadata => F0109TricornD12Metadata.instance;

  @override
  List<F0109TricornD12Preset> get presets => F0109TricornD12Presets.all;

  @override
  List<F0109TricornD12Variant> get variants => F0109TricornD12Variants.all;

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
